# frozen_string_literal: true 

require'roda'
require 'yaml'
require_relative '../require_app'

module Eventure 
  class App < Roda 
    CONFIG = if File.exist?('config/secrets.yml')
              YAML.safe_load_file('config/secrets.yml')
            else 
              {}
            end 
    # if we will add an api key later on         
    #API_KEY = CONFIG['HCCG_API_KEY'] if CONFIG['HCCG_API_KEY']
  end 
end 