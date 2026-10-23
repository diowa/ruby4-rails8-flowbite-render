# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Christmas page' do
  describe 'GET /christmas' do
    subject(:rendered_page) { Capybara.string(response.body) }

    before { get christmas_path }

    it { expect(response).to have_http_status(:ok) }

    it { is_expected.to have_css('title', text: 'Merry Christmas', exact_text: true, visible: :all) }

    it { is_expected.to have_css('h1', text: 'Merry Christmas', exact_text: true) }

    it 'renders the shared navigation and footer' do
      expect(rendered_page)
        .to have_link('Merry Christmas', href: christmas_path, exact_text: true)
        .and have_link('Hello World', href: hello_world_path, exact_text: true)
        .and have_css('footer')
    end

    it 'renders every translated countdown label and greeting' do
      expect(rendered_page.text).to include(
        'Days', 'Hours', 'Minutes', 'Seconds', 'Merry Christmas! May your day be filled with joy.'
      )
    end
  end

  describe 'preserved pages' do
    it 'keeps the home page and its technology versions' do
      get root_path

      expected_content = ['Rails 8 Starter App', '1.0.0', 'Ruby', '4.0.6', 'Rails', '8.1.3',
                          'Tailwind CSS', '4.3.0', 'Flowbite', '3.1.2', 'Font Awesome (Iconmap)', '7.2.0',]
      expect(response.body).to include(*expected_content)
    end

    it 'keeps the Hello World page' do
      get hello_world_path

      rendered_page = Capybara.string(response.body)
      expect(rendered_page)
        .to have_css('title', text: 'Hello World', exact_text: true, visible: :all)
        .and have_css('h1', text: 'Hello World', exact_text: true)
    end
  end

  it 'uses the existing English locale' do
    locale_files = Rails.root.glob('config/locales/*.yml').map { |path| path.basename.to_s }

    expect([locale_files, I18n.default_locale, I18n.t('shared.navbar.christmas')])
      .to eq([['en.yml'], :en, 'Merry Christmas'])
  end
end
