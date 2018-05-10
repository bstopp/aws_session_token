# frozen_string_literal: true

require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'semver'
def s_version
  SemVer.find.format '%M.%m.%p%s'
end

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = 'aws_sesn_token'
  gem.homepage = 'http://github.com/bstopp/aws_sesn_token'
  gem.license = 'Apache2'
  gem.summary = 'Create & Store AWS Session Tokens'
  gem.description = <<~DESC
    Tool to wrap AWS API to create and store Session tokens so that other commands/tools (e.g. Terraform) can function as necessary.
  DESC
  gem.email = 'bryan.stopp@gmail.com'
  gem.authors = ['Bryan Stopp']
  gem.version = s_version
  gem.required_ruby_version = '>= 2.3'

  # dependencies defined in Gemfile
end

Juwelier::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task :headers do
  require 'rubygems'
  require 'copyright_header'

  description = <<~DESC
    Tool to wrap AWS API to create and store Session tokens so that other
    commands/tools (e.g. Terraform) can function as necessary
  DESC

  args = {
    license: 'ASL2',
    copyright_software: 'AWS Session Token Gem',
    copyright_software_description: description,
    copyright_holders: ['Bryan Stopp <bryan.stopp@gmail.com>'],
    copyright_years: ['2018'],
    add_path: 'lib:bin:spec',
    output_dir: '.'
  }

  command_line = CopyrightHeader::CommandLine.new(args)
  command_line.execute
end

require 'yard'
YARD::Rake::YardocTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %i[spec rubocop]
