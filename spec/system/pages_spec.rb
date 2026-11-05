# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  describe 'Home' do
    it 'has application name in title' do
      visit root_path

      expect(page).to have_title t('app_name')
    end
  end

  describe 'Hello World' do
    it 'greets the world with a home-styled heading' do
      visit '/hello_world'

      expect(page).to have_css('h1.text-5xl.font-medium.leading-none.mb-3', text: 'Hello, World!', exact_text: true)
    end

    it 'greets a named visitor with a home-styled heading' do
      visit '/hello_world?name=Ada'

      expect(page).to have_css('h1.text-5xl.font-medium.leading-none.mb-3', text: 'Hello, Ada!', exact_text: true)
    end

    it 'greets the world for an empty name' do
      visit '/hello_world?name='

      expect(page).to have_css('h1', text: 'Hello, World!', exact_text: true)
    end

    it 'greets the world for a whitespace-only name' do
      visit '/hello_world?name=%20%20'

      expect(page).to have_css('h1', text: 'Hello, World!', exact_text: true)
    end

    it 'preserves spaces around a nonblank name' do
      visit '/hello_world?name=%20Ada%20'

      expect(page.find('h1').native.text).to eq('Hello,  Ada !')
    end

    it 'escapes HTML in the name', :aggregate_failures do
      visit '/hello_world?name=%3Cem%3EAda%3C%2Fem%3E'

      expect(page).to have_css('h1', text: 'Hello, <em>Ada</em>!', exact_text: true)
      expect(page).to have_no_css('h1 em')
    end
  end
end
