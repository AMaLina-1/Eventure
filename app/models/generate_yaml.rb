# frozen_string_literal: true

require 'yaml'
require_relative 'gateways/hccg_api'

data = Eventure::Hccg::Api.new.parsed_json(100)

File.write('spec/fixtures/results.yml', data.to_yaml)
