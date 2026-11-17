# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

class WorkflowCommandDocumentation
  SECTION_PATTERN = /^## Reproducing CI and lint checks locally$.*?(?=^## |\z)/m
  WORKFLOW_PATHS = %w[.github/workflows/ci.yml .github/workflows/lint.yml].freeze

  def initialize(project_root)
    @project_root = project_root
  end

  def missing_commands
    commands_and_sources.to_a.filter_map do |command, sources|
      [command, sources] unless readme_section.include?(command)
    end.to_h
  end

  def failure_message(missing_commands)
    details = missing_commands.map do |command, sources|
      "#{command.inspect} (from #{sources.uniq.join(', ')})"
    end.join("\n")

    "README is missing workflow commands:\n#{details}"
  end

  private

  attr_reader :project_root

  def readme_section
    @readme_section ||= File.read(File.join(project_root, 'README.md'))[SECTION_PATTERN].to_s
  end

  def commands_and_sources
    WORKFLOW_PATHS.each_with_object(Hash.new { |commands, command| commands[command] = [] }) do |relative_path, commands|
      workflow_commands(relative_path).each { |command| commands[command] << relative_path }
    end
  end

  def workflow_commands(relative_path)
    workflow = YAML.safe_load_file(File.join(project_root, relative_path), aliases: true)

    workflow.fetch('jobs').each_value.flat_map do |job|
      job.fetch('steps', []).filter_map { |step| step['run']&.strip }
    end
  end
end

RSpec.describe WorkflowCommandDocumentation do
  subject(:documentation) { described_class.new(File.expand_path('..', __dir__)) }

  it 'documents every command run by the CI and lint workflows' do
    missing_commands = documentation.missing_commands

    expect(missing_commands).to be_empty, documentation.failure_message(missing_commands)
  end
end
