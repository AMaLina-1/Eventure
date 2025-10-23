# frozen_string_literal: true

require_relative 'require_app'
require_app

def app = Eventure::App

require_relative 'app/infrastructure/database/orm/activity_orm'
require_relative 'app/infrastructure/database/orm/relatedata_orm'
require_relative 'app/infrastructure/database/orm/tag_orm'

include Eventure::Database
