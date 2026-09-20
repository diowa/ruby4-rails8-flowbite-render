# Rails 8 Starter App
[![Build Status](https://github.com/diowa/ruby4-rails8-flowbite-render/actions/workflows/ci.yml/badge.svg)](https://github.com/diowa/ruby4-rails8-flowbite-render/actions)
[![Maintainability](https://qlty.sh/gh/diowa/projects/ruby4-rails8-flowbite-render/maintainability.svg)](https://qlty.sh/gh/diowa/projects/ruby4-rails8-flowbite-render)
[![Coverage Status](https://coveralls.io/repos/github/diowa/ruby4-rails8-flowbite-render/badge.svg?branch=main)](https://coveralls.io/github/diowa/ruby4-rails8-flowbite-render?branch=main)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

This is an opinionated starter web application based on the following technology stack:

* [Ruby 4.0.6][:ruby-url]
* [Rails 8.1.3.1][:ruby-on-rails-url]
* [Tailwind CSS 4.3.0][:tailwind-css-url]
* [Flowbite 3.1.2][:flowbite-url]
* [Puma][:puma-url]
* [PostgreSQL][:postgresql-url]
* [RSpec][:rspec-url]
* [Font Awesome SVG 7.2.0][:fontawesome-url] (via [Iconmap for Rails](:iconmap-url))
* [RuboCop][:rubocop-url]
* [RuboCop RSpec][:rubocop-rspec-url]
* [stylelint][:stylelint-url]
* [i18n-tasks][:i18n-tasks-url]

[:flowbite-url]: https://flowbite.com/
[:fontawesome-url]: https://fontawesome.com
[:iconmap-url]: https://github.com/tagliala/iconmap-rails
[:i18n-tasks-url]: https://github.com/glebm/i18n-tasks
[:postgresql-url]: https://www.postgresql.org
[:puma-url]: https://puma.io
[:rspec-url]: https://rspec.info
[:rubocop-rspec-url]: https://github.com/backus/rubocop-rspec
[:rubocop-url]: https://github.com/bbatsov/rubocop
[:ruby-on-rails-url]: https://rubyonrails.org
[:ruby-url]: https://www.ruby-lang.org/en/
[:stylelint-url]: https://stylelint.io
[:tailwind-css-url]: https://tailwindcss.com/

Starter App is deployable on [Render](https://render.com/). Demo: https://ruby4-rails8-flowbite-render-app.onrender.com/

```Gemfile``` also contains a set of useful gems for performance, security, api building...

## Reproducing CI and lint checks locally

The commands below come from [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and [`.github/workflows/lint.yml`](.github/workflows/lint.yml).

Preparation commands:

```sh
bundle exec rails db:prepare
pnpm install
pnpm install @csstools/stylelint-formatter-github
```

Checks:

```sh
bundle exec rake spec
bundle exec rubocop --format github
bundle exec i18n-tasks health
pnpm lint
pnpm stylelint app/**/*.{scss,css} --custom-formatter @csstools/stylelint-formatter-github
```

CI runs the database preparation and specs with `RAILS_ENV=test` and a PostgreSQL connection configured through `DATABASE_URL`.
