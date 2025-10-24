# frozen_string_literal: true

def require_app
  # Load config files first
  Dir.glob('./config/**/*.rb').sort.each { |file| require file }

  # Load models first (important for DatabaseHelper)
  Dir.glob('./app/models/**/*.rb').sort.each { |file| require file }

  # Load database files next
  Dir.glob('./app/infrastructure/database/**/*.rb').sort.each { |file| require file }

  # Load everything else in app
  Dir.glob('./app/**/*.rb').sort.each do |file|
    require file unless file.include?('/models/') || file.include?('/database/')
  end
end
