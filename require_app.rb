# frozen_string_literal: true

def require_app
  # Load config files first
  Dir.glob('./config/**/*.rb').each { |file| require file }

  # Load models first (important for DatabaseHelper)
  Dir.glob('./app/models/**/*.rb').each { |file| require file }

  # Load database files next
  Dir.glob('./app/infrastructure/database/**/*.rb').each { |file| require file }

  # Load everything else in app
  Dir.glob('./app/**/*.rb').each do |file|
    require file unless file.include?('/models/') || file.include?('/database/')
  end
end
