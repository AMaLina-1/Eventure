# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    Eventure::App.db.run('PRAGMA foreign_keys = OFF')
    Eventure::Database::ActivityOrm.map(&:destroy)
    Eventure::Database::TagOrm.map(&:destroy)
    Eventure::Database::RelatedataOrm.map(&:destroy)
    Eventure::App.db.run('PRAGMA foreign_keys = ON')
  end
end
