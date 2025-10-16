# frozen_string_literal: true

def require_app
  Dir.glob('./{config,app}/**/*.rb').each do |file|
    require file
  end
end