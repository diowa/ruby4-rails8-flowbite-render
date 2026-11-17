# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Christmas countdown', :aggregate_failures, :js do
  def travel_browser_to(instant, update: true)
    timestamp = (Time.iso8601(instant).to_f * 1000).to_i

    page.execute_script(<<~JAVASCRIPT, timestamp, update)
      const NativeDate = window.__christmasNativeDate || window.Date
      window.__christmasNativeDate = NativeDate
      window.__christmasNow = arguments[0]
      window.Date = class extends NativeDate {
        constructor(...values) {
          super(...(values.length === 0 ? [window.__christmasNow] : values))
        }

        static now() {
          return window.__christmasNow
        }
      }

      if (arguments[1]) {
        const element = document.querySelector('[data-controller="christmas-countdown"]')
        window.Stimulus.getControllerForElementAndIdentifier(element, 'christmas-countdown').update()
      }
    JAVASCRIPT
  end

  def countdown_values
    %w[days hours minutes seconds].to_h do |unit|
      selector = "[data-christmas-countdown-target='#{unit}']"
      [unit.to_sym, find(selector).text]
    end
  end

  def emulate_color_scheme(scheme)
    page.driver.browser.execute_cdp(
      'Emulation.setEmulatedMedia',
      features: [{ name: 'prefers-color-scheme', value: scheme }]
    )
  end

  def emulate_time_zone(time_zone)
    page.driver.browser.execute_cdp('Emulation.setTimezoneOverride', timezoneId: time_zone)
  end

  def verify_live_countdown
    visit christmas_path
    travel_browser_to('2025-12-24T22:59:57.500Z')

    expect(countdown_values).to eq(days: '0', hours: '00', minutes: '00', seconds: '03')

    travel_browser_to('2025-12-24T22:59:58.500Z', update: false)
    expect(page).to have_css("[data-christmas-countdown-target='seconds']", text: '02', exact_text: true)

    travel_browser_to('2025-12-01T12:00:00.000Z', update: false)
    expect(page).to have_css("[data-christmas-countdown-target='days']", text: '23', exact_text: true)
    :verified
  end

  it('rounds up, updates, and corrects a suspended countdown') { expect(verify_live_countdown).to eq(:verified) }

  def verify_christmas_day(instant)
    travel_browser_to(instant)

    expect(countdown_values).to eq(days: '0', hours: '00', minutes: '00', seconds: '00')
    expect(page).to have_css("[data-christmas-countdown-target='greeting']", visible: :visible)
  end

  def verify_countdown_after_christmas(instant, days)
    travel_browser_to(instant)

    expect(countdown_values).to eq(days: days, hours: '00', minutes: '00', seconds: '00')
    expect(page).to have_no_css("[data-christmas-countdown-target='greeting']", visible: :visible)
  end

  def verify_christmas_transitions
    visit christmas_path
    verify_christmas_day('2025-12-24T23:00:00.000Z')
    verify_christmas_day('2025-12-25T22:59:59.999Z')
    verify_countdown_after_christmas('2025-12-25T23:00:00.000Z', '364')
    verify_countdown_after_christmas('2025-12-31T23:00:00.000Z', '358')
    :verified
  end

  it('handles the December 25 and 26 transitions') { expect(verify_christmas_transitions).to eq(:verified) }

  def verify_zone_combination(browser_zone, server_zone)
    ENV['TZ'] = server_zone
    Time.use_zone(server_zone) do
      emulate_time_zone(browser_zone)
      visit christmas_path
      travel_browser_to('2025-12-24T22:59:59.250Z')

      expect(countdown_values).to eq(days: '0', hours: '00', minutes: '00', seconds: '01')
    end
  end

  def verify_time_zone_independence
    original_process_zone = ENV.fetch('TZ', nil)
    original_rails_zone = Time.zone

    ['UTC', 'Asia/Tokyo'].product(['UTC', 'America/Los_Angeles']).each do |zones|
      verify_zone_combination(*zones)
    end
    :verified
  ensure
    ENV['TZ'] = original_process_zone
    expect(Time.zone).to eq(original_rails_zone)
  end

  it('does not depend on browser or server time zones') { expect(verify_time_zone_independence).to eq(:verified) }

  def start_tracked_timer
    visit christmas_path
    travel_browser_to('2025-12-24T22:59:58.500Z')
    page.execute_script(<<~JAVASCRIPT)
      const element = document.querySelector('[data-controller="christmas-countdown"]')
      const controller = window.Stimulus.getControllerForElementAndIdentifier(element, 'christmas-countdown')
      window.__christmasTimer = controller.timer
      window.__clearedChristmasTimers = []
      const nativeClearInterval = window.clearInterval
      window.clearInterval = (timer) => {
        window.__clearedChristmasTimers.push(timer)
        nativeClearInterval(timer)
      }
    JAVASCRIPT
  end

  def leave_christmas_page
    start_tracked_timer
    click_link 'Hello World'

    expect(page).to have_current_path(hello_world_path)
    expect(page.evaluate_script('window.__clearedChristmasTimers.includes(window.__christmasTimer)')).to be(true)
  end

  def return_to_christmas_page
    travel_browser_to('2025-12-24T22:59:59.250Z', update: false)
    page.go_back

    expect(page).to have_current_path(christmas_path)
    expect(countdown_values).to eq(days: '0', hours: '00', minutes: '00', seconds: '01')
  end

  def verify_turbo_timer_lifecycle
    leave_christmas_page
    return_to_christmas_page
    :verified
  end

  it('stops and restarts the timer across Turbo visits') { expect(verify_turbo_timer_lifecycle).to eq(:verified) }

  def accessibility_metrics
    page.evaluate_script(<<~JAVASCRIPT)
      (() => {
        const root = document.documentElement
        const content = [
          document.getElementById('christmas-title'),
          document.getElementById('christmas-countdown'),
          document.querySelector('[data-christmas-countdown-target="greeting"]'),
        ]
        const text = [
          document.getElementById('christmas-title'),
          ...document.querySelectorAll('#christmas-countdown span'),
          document.querySelector('[data-christmas-countdown-target="greeting"]'),
          document.querySelector('a[href="/christmas"]'),
        ]
        const canvas = document.createElement('canvas')
        canvas.width = 1
        canvas.height = 1
        const context = canvas.getContext('2d', { willReadFrequently: true })
        const channels = (color) => {
          context.clearRect(0, 0, 1, 1)
          context.fillStyle = color
          context.fillRect(0, 0, 1, 1)
          return Array.from(context.getImageData(0, 0, 1, 1).data)
        }
        const backgroundFor = (element) => {
          let current = element
          while (current) {
            const color = channels(getComputedStyle(current).backgroundColor)
            if (color[3] > 0) return color
            current = current.parentElement
          }
          return [255, 255, 255, 255]
        }
        const luminance = (color) => {
          const linear = color.slice(0, 3).map((channel) => {
            const value = channel / 255
            return value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4
          })
          return (0.2126 * linear[0]) + (0.7152 * linear[1]) + (0.0722 * linear[2])
        }
        const contrast = (element) => {
          const foreground = luminance(channels(getComputedStyle(element).color))
          const background = luminance(backgroundFor(element))
          return (Math.max(foreground, background) + 0.05) / (Math.min(foreground, background) + 0.05)
        }

        return {
          background: getComputedStyle(document.body).backgroundColor,
          contained: content.every((element) => {
            const rectangle = element.getBoundingClientRect()
            return rectangle.left >= 0 && rectangle.right <= root.clientWidth
          }),
          minimumContrast: Math.min(...text.map(contrast)),
          noOverflow: root.scrollWidth <= root.clientWidth,
        }
      })()
    JAVASCRIPT
  end

  def verify_color_scheme(scheme)
    emulate_color_scheme(scheme)
    metrics = accessibility_metrics
    checks = [
      metrics.fetch('noOverflow'),
      metrics.fetch('contained'),
      metrics.fetch('minimumContrast') >= 4.5,
      page.has_link?('Merry Christmas', href: christmas_path, visible: :visible),
    ]

    expect(checks).to all(be(true))
    metrics.fetch('background')
  end

  def verify_viewport(width, height)
    page.current_window.resize_to(width, height)
    find("button[aria-controls='main-navbar']").click if width == 375

    %w[light dark].index_with { |scheme| verify_color_scheme(scheme) }
  end

  def verify_responsive_themes
    visit christmas_path
    travel_browser_to('2025-12-25T12:00:00.000Z')
    backgrounds = {
      375 => verify_viewport(375, 667),
      1024 => verify_viewport(1024, 768),
    }

    expect(backgrounds.values).to all(satisfy { |colors| colors.fetch('dark') != colors.fetch('light') })
    :verified
  end

  it('supports both responsive navigation and color schemes') { expect(verify_responsive_themes).to eq(:verified) }
end
