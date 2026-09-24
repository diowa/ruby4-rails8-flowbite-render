# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Page theme', :js do
  before do
    visit root_path
    page.execute_script("localStorage.removeItem('theme')")
  end

  after do
    page.driver.browser.execute_cdp('Emulation.setEmulatedMedia', features: [])
    page.driver.browser.execute_cdp('Emulation.clearDeviceMetricsOverride')
  end

  def emulate_os_theme(value)
    page.driver.browser.execute_cdp('Emulation.setEmulatedMedia', features: [{ name: 'prefers-color-scheme', value: value }])
  end

  def expect_theme(theme, saved: nil)
    expect(page).to have_css('html.dark') if theme == 'dark'
    expect(page).to have_no_css('html.dark') if theme == 'light'
    pressed = theme == 'dark' ? 'true' : 'false'
    next_theme = theme == 'dark' ? 'light' : 'dark'
    expect(page).to have_css("[data-theme-toggle][aria-pressed='#{pressed}'][aria-label='Switch to #{next_theme} theme']")
    expect_saved_theme(saved)
  end

  def expect_saved_theme(value)
    expect(page.evaluate_script("localStorage.getItem('theme')")).to eq(value)
  end

  def color(selector, property)
    page.evaluate_script("getComputedStyle(document.querySelector(#{selector.to_json})).getPropertyValue(#{property.to_json})")
  end

  def expect_colors(theme)
    shades = theme == 'dark' ? %w[800 900 300 700] : %w[white 100 600 200]
    selectors = [['body', 'background-color'], ['nav', 'background-color'], ['main small', 'color'], ['footer hr', 'background-color']]
    selectors.zip(shades).each do |(selector, property), shade|
      expected = page.evaluate_script(<<~JS)
        (() => {
          const sample = document.createElement('span')
          sample.style.color = 'var(--color-#{shade == 'white' ? 'white' : "gray-#{shade}"})'
          document.body.append(sample)
          const result = getComputedStyle(sample).color
          sample.remove()
          return result
        })()
      JS
      expect(color(selector, property)).to eq(expected)
    end
  end

  %w[dark light no-preference].each do |os_theme|
    # rubocop:disable-next RSpec/ExampleLength
    it "follows #{os_theme} OS preference until a manual selection" do
      # Chromium treats no preference as light for the dark media query.
      emulate_os_theme(os_theme == 'no-preference' ? 'light' : os_theme)
      visit root_path
      expected = os_theme == 'dark' ? 'dark' : 'light'
      expect_theme(expected)
      expect_colors(expected)

      opposite = expected == 'dark' ? 'light' : 'dark'
      emulate_os_theme(opposite)
      expect_theme(opposite)
      expect_colors(opposite)
    end
  end

  # rubocop:disable-next RSpec/ExampleLength, RSpec/MultipleExpectations
  it 'switches by pointer, Enter and Space, retaining explicit choices against OS changes' do
    emulate_os_theme('light')
    visit root_path
    button = find('[data-theme-toggle]')
    button.click
    expect_theme('dark', saved: 'dark')
    expect_colors('dark')
    emulate_os_theme('light')
    expect_theme('dark', saved: 'dark')

    button.send_keys(:enter)
    expect_theme('light', saved: 'light')
    expect_colors('light')
    emulate_os_theme('dark')
    expect_theme('light', saved: 'light')

    button.send_keys(:space)
    expect_theme('dark', saved: 'dark')
    expect(page.evaluate_script("document.activeElement.matches('[data-theme-toggle]')")).to be(true)
    expect(color('[data-theme-toggle]', 'outline-style')).not_to eq('none')
  end

  { mobile: [375, 812], desktop: [1280, 800] }.each do |layout, (width, height)|
    # rubocop:disable-next RSpec/ExampleLength, RSpec/MultipleExpectations
    it "keeps both themes and navigation functional at #{layout} width through Turbo and reloads" do
      page.driver.browser.execute_cdp('Emulation.setDeviceMetricsOverride', width: width, height: height, deviceScaleFactor: 1, mobile: false)
      expect(page.evaluate_script('[window.innerWidth, window.innerHeight]')).to eq([width, height])
      emulate_os_theme('dark')
      visit root_path
      find('[data-theme-toggle]').click
      expect_theme('light', saved: 'light')
      expect_colors('light')
      page.execute_script('window.navigationMarker = true')

      if layout == :mobile
        menu = find('button[aria-controls="main-navbar"]')
        expect(menu['aria-expanded']).to eq('false')
        expect(page).to have_no_css('#main-navbar', visible: :visible)
        menu.click
        expect(menu['aria-expanded']).to eq('true')
        expect(page).to have_css('#main-navbar', visible: :visible)
        menu.click
        expect(menu['aria-expanded']).to eq('false')
        expect(page).to have_no_css('#main-navbar', visible: :visible)
        menu.click
      else
        expect(page).to have_link('Hello World', visible: :visible)
      end

      click_link 'Hello World'
      expect(page).to have_current_path(hello_world_path)
      expect(page.evaluate_script('window.navigationMarker')).to be(true)
      expect_theme('light', saved: 'light')
      if layout == :mobile
        expect(find('button[aria-controls="main-navbar"]')['aria-expanded']).to eq('false')
        expect(page).to have_no_css('#main-navbar', visible: :visible)
      end
      find('[data-theme-toggle]').click
      expect_theme('dark', saved: 'dark')
      emulate_os_theme('light')
      expect_theme('dark', saved: 'dark')

      click_link t('app_name')
      expect(page).to have_current_path(root_path)
      expect(page.evaluate_script('window.navigationMarker')).to be(true)
      expect_theme('dark', saved: 'dark')
      expect_colors('dark')
      if layout == :mobile
        expect(find('button[aria-controls="main-navbar"]')['aria-expanded']).to eq('false')
        expect(page).to have_no_css('#main-navbar', visible: :visible)
        find('button[aria-controls="main-navbar"]').click
        expect(page).to have_css('#main-navbar', visible: :visible)
      end
      click_link 'Hello World'
      expect(page).to have_current_path(hello_world_path)
      page.go_back
      expect(page).to have_current_path(root_path)
      expect(page.evaluate_script('window.navigationMarker')).to be(true)
      expect_theme('dark', saved: 'dark')
      if layout == :mobile
        expect(find('button[aria-controls="main-navbar"]')['aria-expanded']).to eq('true')
        expect(page).to have_css('#main-navbar', visible: :visible)
      end

      page.refresh
      expect(page.evaluate_script('window.navigationMarker')).to be_nil
      expect_theme('dark', saved: 'dark')
      emulate_os_theme('dark')
      find('[data-theme-toggle]').click
      expect_theme('light', saved: 'light')
      expect_colors('light')
      page.refresh
      expect_theme('light', saved: 'light')
      expect_colors('light')
      expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)

      find('button[aria-controls="main-navbar"]').click if layout == :mobile
      click_link 'Hello World'
      expect(page).to have_current_path(hello_world_path)
      expect_theme('light', saved: 'light')
      if layout == :mobile
        expect(find('button[aria-controls="main-navbar"]')['aria-expanded']).to eq('false')
        expect(page).to have_no_css('#main-navbar', visible: :visible)
      end
      page.go_back
      expect(page).to have_current_path(root_path)
      expect_theme('light', saved: 'light')
      if layout == :mobile
        expect(find('button[aria-controls="main-navbar"]')['aria-expanded']).to eq('true')
        expect(page).to have_css('#main-navbar', visible: :visible)
      end
    end
  end
end
