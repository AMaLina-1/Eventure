# frozen string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'

require 'vcr'
require 'webmock'

require_relative '../lib/hccg/http_request'

TOP = 10
CONFIG = YAML.safe_load_file('config/secrets.yml') if File.exist?('config/secrets.yml')
# API_KEY = CONFIG['API_KEY']
CORRECT = YAML.safe_load_file('spec/fixtures/results.yml')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'hccg_api'