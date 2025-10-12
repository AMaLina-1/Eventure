# frozen_string_literal: true

require 'rake/testtask'
require 'fileutils'

CODE = 'lib/'

task :default do 
  puts `rake -T`
end

desc 'Run all tests'
task :spec do
  sh 'ruby spec/hccg_api_spec.rb'
end

namespace :vcr do
  CASSETTE_DIR = 'spec/fixtures/cassettes'

  desc 'Delete all VCR cassette files'
  task :wipe do
    if Dir.exist?(CASSETTE_DIR)
      files = Dir.glob("#{CASSETTE_DIR}/*.yml")
      if files.empty?
        puts 'No cassettes found'
      else 
        FileUtils.rm_rf(files)
        puts 'Cassettes deleted'
      end
    else
      puts 'No cassette directory found'
    end
  end
end

namespace :quality do
  desc 'Run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'Code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'Code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'Complexity analysis'
  task :flog do
    sh "flog #{CODE}"
  end
end
