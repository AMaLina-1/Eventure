# frozen_string_literal: true

module HccgEventure
  API_BASE   = ENV.fetch('HCCG_API_BASE', 'https://webopenapi.hccg.gov.tw')
  TIMEOUT_S  = Integer(ENV.fetch('HCCG_TIMEOUT', '10'))
  USER_AGENT = 'HccgEventure/0.1 (+https://github.com/your-org/your-repo)'
end

require_relative 'errors'
require_relative 'models/activity'
require_relative 'eventure_api'
