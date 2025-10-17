# frozen_string_literal: true

def require_app
  Dir.glob('./{config,app,lib}/**/*.rb').each do |file|
    require file
  end
end