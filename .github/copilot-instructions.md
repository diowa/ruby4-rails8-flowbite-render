# Rails 8 Starter App - Copilot Instructions

This is a Ruby on Rails 8 web application with Tailwind CSS 4, Flowbite, Font Awesome, PostgreSQL, and comprehensive tooling for linting, testing, and deployment to Render.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Prerequisites

Install these dependencies on the system before starting:
- Ruby (version specified in .ruby-version)
- Node.js (version specified in package.json)
- PostgreSQL
- pnpm (version specified in package.json)
- bundler gem

## Bootstrap and Setup

Run these commands to set up the development environment from a fresh clone:

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update && sudo apt-get install -y postgresql postgresql-contrib
sudo service postgresql start
sudo -u postgres createuser -s $USER

# Install pnpm if not present
npm install -g pnpm

# Set up bundle path to avoid permission issues
bundle config set --local path vendor/bundle

# Install Ruby dependencies (NEVER CANCEL: takes ~1 minute)
bundle install

# Install JavaScript dependencies (NEVER CANCEL: takes ~30 seconds)
pnpm install

# Set up database (NEVER CANCEL: takes ~2 seconds)
bundle exec rails db:prepare
```

**CRITICAL TIMING NOTE**:
- First-time bundle install takes approximately 45 seconds to 1 minute
- First-time pnpm install takes approximately 30 seconds
- Subsequent installs are much faster (cached dependencies)
- NEVER CANCEL these operations as they are downloading and compiling dependencies

## Running the Application

Start the development server:
```bash
bundle exec rails server
# OR
bin/rails server
```

The application runs on http://localhost:3000 and displays a homepage with application version info and technology stack details.

**Application Features to Test**:
- Homepage loads with "Rails 8 Starter App 1.0.0" heading
- Navigation bar with "Rails 8 Starter App" link
- "Hello World" link in navigation
- Footer with GitHub repository link
- Tailwind CSS styling and responsive layout
- Font Awesome icons rendered correctly
- Flowbite components working correctly

## Testing and Quality Assurance

Run the complete test and lint suite:
```bash
# Run all linters (NEVER CANCEL: takes ~6 seconds)
bundle exec rake lint
```

This command runs:
- RuboCop (Ruby style and quality)
- i18n-tasks (translation validation)
- oxlint via pnpm (JavaScript linting)
- stylelint via pnpm (CSS/SCSS linting)

Run the test suite:
```bash
# Run all specs (NEVER CANCEL: takes ~5-16 seconds depending on cache)
bundle exec rake spec
```

The test suite includes:
- System tests using Capybara and Selenium WebDriver
- Currently has 1 example testing the homepage
- Generates coverage reports in coverage/ directory
- Uses SimpleCov with LCOV format output
- First run takes longer (~16s), subsequent runs are faster (~5s)

## Build and Asset Compilation

Compile Tailwind CSS assets:
```bash
# Tailwind CSS compilation (NEVER CANCEL: takes ~5 seconds)
bundle exec rails tailwindcss:build

# OR Rails asset precompilation
bundle exec rails assets:precompile
```

**Build Warnings**: The build may show warnings for Tailwind CSS features. These are expected and do not indicate build failures.

## Development Workflow

Always run these commands before committing changes:
```bash
# Lint and fix code style issues
bundle exec rake lint

# Run tests to ensure nothing is broken
bundle exec rake spec

# Compile assets to verify build works
bundle exec rails tailwindcss:build
```

**VALIDATION SCENARIOS**: After making changes, always test:
1. **Homepage loads**: Visit http://localhost:3000 and verify page displays correctly
2. **Navigation works**: Click "Hello World" link and verify it navigates properly
3. **Responsive layout**: Test on different screen sizes to ensure Tailwind CSS responsive design works
4. **Asset loading**: Verify CSS styles and JavaScript functionality work correctly
5. **Flowbite components**: Test any Flowbite components for proper functionality

## Commit Message Guidelines
Follow the project's commit message standards as outlined in [CONTRIBUTING.md](../CONTRIBUTING.md):

- **Reference**: Follow [How to Write a Git Commit Message](https://cbea.ms/git-commit/#seven-rules)
- **Format**: Use imperative mood ("Add feature" not "Added feature")
- **Length**: Limit subject line to 50 characters, body lines to 72 characters
- **Structure**:
  ```
  Short summary (50 chars max)

  Detailed explanation if needed (72 chars per line)

  - Use bullet points for multiple changes
  - Reference issues with "Fixes #123" or "Closes #456"
  ```
- **Examples**:
  ```
  Fix temporal query performance regression

  Add support for Rails 8.0 compatibility

  Update dependencies for security patches

  Fixes #123
  ```
- **Best Practices**:
  - Keep commits atomic (one logical change per commit)
  - Write clear, descriptive commit messages
  - Reference related issues and pull requests
  - Avoid generic messages like "Fix bug" or "Update code"

**Branch Naming Conventions**:
Use descriptive branch prefixes to categorize work:
- `feature/` - New features and enhancements
- `bugfix/` - Bug fixes and corrections
- `chore/` - Maintenance, refactoring, CI/CD, dependency updates

## Key File Locations

**Application Structure**:
- `app/controllers/` - Rails controllers
- `app/views/` - ERB template files
- `app/models/` - ActiveRecord models
- `app/javascript/` - JavaScript source files and importmap entry points
- `app/assets/` - Static assets (images, etc.)

**Configuration**:
- `config/routes.rb` - Application routes
- `config/database.yml` - Database configuration
- `config/importmap.rb` - Importmap configuration
- `package.json` - Node.js dependencies and scripts
- `Gemfile` - Ruby gem dependencies

**Testing**:
- `spec/` - RSpec test files
- `spec/system/` - System/integration tests
- `spec/support/` - Test support files

**Tooling Configuration**:
- `.rubocop.yml` - RuboCop linting rules
- `.oxlintrc.json` - JavaScript linting
- `.stylelintrc` - CSS/SCSS linting

## Common Commands Reference

| Command | Purpose | Time | Notes |
|---------|---------|------|-------|
| `bundle install` | Install Ruby gems | ~45s first, ~5s cached | NEVER CANCEL |
| `pnpm install` | Install Node packages | ~30s first, ~2s cached | NEVER CANCEL |
| `bundle exec rails db:prepare` | Set up database | ~2 sec | Creates dev/test DBs |
| `bundle exec rails server` | Start dev server | instant | Runs on port 3000 |
| `bundle exec rake lint` | Run all linters | ~6 sec | Must pass before commit |
| `bundle exec rake spec` | Run test suite | ~5-16 sec | Must pass before commit |
| `bundle exec rails tailwindcss:build` | Compile assets | ~5 sec | Tailwind CSS build |

## Deployment

This application is configured for deployment to:
- **Render**: Demo available at https://ruby3-rails8-flowbite-render-app.onrender.com/
- **Kamal**: Configuration available in `.kamal/` directory

Key deployment files:
- `render.yaml` - Render deployment configuration
- `.kamal/` - Kamal deployment configuration
- `Procfile.dev` - Development process definitions

## Master Key

The Rails master key for development is stored in encrypted credentials.

**SECURITY WARNING**: This is a demo application. Change credentials for any real project.

## Environment Requirements

- Ruby: version specified in .ruby-version
- Node.js: version specified in package.json
- pnpm: version specified in package.json
- PostgreSQL: Any recent version
- Rails: 8.0 (latest within major version)

## Technology Stack Details

**Frontend**:
- **Tailwind CSS 4.x**: Utility-first CSS framework
- **Flowbite 3.x**: Component library built on Tailwind CSS
- **Font Awesome SVG**: Icons via iconmap-rails
- **Importmap**: JavaScript bundling and module loading
- **Stimulus**: JavaScript framework for Rails
- **Turbo**: Single-page application framework

**Backend**:
- **Rails 8.0**: Web application framework
- **PostgreSQL**: Primary database
- **Solid Queue**: Job processing (Rails 8 default)
- **Solid Cache**: Caching (Rails 8 default)
- **Solid Cable**: WebSocket connections (Rails 8 default)
- **Puma**: Web server

**Testing & Quality**:
- **RSpec**: Testing framework
- **Capybara**: System testing
- **RuboCop**: Ruby linting
- **ESLint**: JavaScript linting
- **Stylelint**: CSS linting
- **SimpleCov**: Code coverage

## Troubleshooting

**Permission Errors**: If bundle install fails with permission errors, run:
```bash
bundle config set --local path vendor/bundle
bundle install
```

**Database Connection Issues**: Ensure PostgreSQL is running and user exists:
```bash
sudo service postgresql start
sudo -u postgres createuser -s $USER
```

**Asset Compilation Failures**: Clear compiled assets and rebuild:
```bash
bundle exec rails assets:clobber
bundle exec rails tailwindcss:build
```

**Node.js Version Warnings**: The application requires Node.js >= 22.0 but may work with older versions. Update Node.js if experiencing issues.

**Importmap Issues**: If JavaScript modules are not loading:
```bash
bundle exec rails importmap:install
bin/importmap pin flowbite
```
