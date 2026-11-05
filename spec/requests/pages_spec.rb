# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'GET /' do
    before { get root_path }

    it { expect(response).to have_http_status(:ok) }

    it { expect(response.body).to include('Rails 8 Starter App') }
  end

  describe 'GET /about' do
    subject(:rendered_page) { Capybara.string(response.body) }

    let(:description) { 'This is a starter web application using Ruby, Rails, Tailwind CSS, and Flowbite.' }
    let(:repository_url) { 'https://github.com/diowa/ruby4-rails8-flowbite-render' }

    before { get about_path }

    it { expect(response).to have_http_status(:ok) }

    it { is_expected.to have_css('h1', text: 'About', exact_text: true) }

    it { is_expected.to have_css('p', text: description, exact_text: true) }

    it { is_expected.to have_link('Source code', href: repository_url, exact_text: true) }

    it { expect(response.body).not_to include('Rails 8 Starter App') }
  end

  describe 'GET / and GET /about' do
    let(:home_body) do
      get root_path
      response.body
    end
    let(:about_body) do
      get about_path
      response.body
    end

    it { expect(about_body).not_to eq(home_body) }
  end
end
