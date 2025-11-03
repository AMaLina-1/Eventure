# frozen_string_literal: true

require 'rake/testtask'
require 'fileutils'
require_relative 'require_app'

CODE = 'app/**/*.rb'
CASSETTE_DIR = 'spec/fixtures/cassettes'

task :default do
  puts 'rake -T'
end

desc 'Generates a 64 by secret for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(it) }
  puts "SESSION_SECRET: #{secret}"
end

desc 'Run all tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning tests when files change'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Run web app'
task :run do
  sh 'bundle exec puma'
end

desc 'Keep rerunning web app when files change'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' -- bundle exec puma"
end

namespace :vcr do
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

# rubocop:disable Metrics/BlockLength
namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = Eventure::App
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app(%w[models infrastructure])
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(Eventure::App.config.DB_FILENAME)
    puts "Deleted #{Eventure::App.config.DB_FILENAME}"
  end
end
# rubocop:enable Metrics/BlockLength

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all.rb'
end
