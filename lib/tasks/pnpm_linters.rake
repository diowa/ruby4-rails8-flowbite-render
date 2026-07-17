# frozen_string_literal: true

namespace :pnpm do
  # rubocop:disable Rails/RakeEnvironment
  task :run, %i[command] do |_, args|
    # Install only production deps when for not usual envs.
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch('NODE_ENV') do
      valid_node_envs.include?(Rails.env) ? Rails.env : 'production'
    end

    system(
      { 'NODE_ENV' => node_env },
      "pnpm #{args[:command]}",
      exception: true
    )
  rescue Errno::ENOENT
    warn 'pnpm was not found.'
    exit 1
  end

  desc 'Run `pnpm stylelint app/**/*.{scss,css}`'
  task :stylelint do
    extra_args = ARGV[2..]&.join(' ')
    cmd = ['stylelint', Dir.glob('app/**/*.{scss,css}').join(' '), extra_args].compact.join(' ')
    Rake::Task['pnpm:run'].execute(command: cmd)
  end

  desc 'Run `pnpm lint` (oxlint)'
  task :lint do
    extra_args = ARGV[2..]&.join(' ')
    cmd = ['lint', extra_args].compact.join(' ')
    Rake::Task['pnpm:run'].execute(command: cmd)
  end
  # rubocop:enable Rails/RakeEnvironment
end

task(:lint).sources.push 'pnpm:stylelint'
task(:lint).sources.push 'pnpm:lint'
