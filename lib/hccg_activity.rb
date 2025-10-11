# frozen_string_literal: true

require 'json'
require 'uri'
require 'http'
require 'yaml'
require 'fileutils'

module HccgEventure
  API_BASE   = ENV.fetch('HCCG_API_BASE', 'https://webopenapi.hccg.gov.tw')
  TIMEOUT_S  = Integer(ENV.fetch('HCCG_TIMEOUT', '10'))
  USER_AGENT = 'HccgEventure/0.1 (+https://github.com/your-org/your-repo)'

  ACTIVITY_FIELDS = %w[
    pubunitname
    subject
    detailcontent
    subjectclass
    serviceclass
    voice
    hostunit
    joinunit
    activitysdate
    activityedate
    activityplace
  ].freeze

  class Activity
    attr_reader(*ACTIVITY_FIELDS.map(&:to_sym))

    # Accept hash with string or symbol keys. Defensive: treat nil as empty hash.
    def initialize(raw_hash = {})
      raw_hash = {} unless raw_hash.is_a?(Hash)
      ACTIVITY_FIELDS.each do |k|
        val = raw_hash[k] || raw_hash[k.to_sym]
        instance_variable_set(:"@#{k}", val)
      end
    end

    # Return a hash with symbol keys
    def to_h
      ACTIVITY_FIELDS.each_with_object({}) do |k, acc|
        acc[k.to_sym] = instance_variable_get(:"@#{k}")
      end
    end

    def to_json(*)
      to_h.to_json
    end
  end

  class HTTPError < StandardError
    attr_reader :status, :body
    def initialize(message = 'HTTP error', status: nil, body: nil)
      super(message)
      @status = status
      @body   = body
    end
  end

  class Client
    def initialize(base_url: API_BASE)
      @base_url = base_url
      @http = HTTP.timeout(connect: TIMEOUT_S, read: TIMEOUT_S)
                  .headers('Accept' => 'application/json', 'User-Agent' => USER_AGENT)
    end

    def activities(top: 100, query: nil)
      raise ArgumentError, 'top must be positive' unless top.to_i.positive?

      path = '/v1/Activity'
      params = { top: top }
      params[:query] = query if query

      json = get_json(path, params: params)
      Array(json).map do |row|
        picked = if row.respond_to?(:slice)
                   row.slice(*ACTIVITY_FIELDS)
                 else
                   slice_fallback(row, ACTIVITY_FIELDS)
                 end
        Activity.new(picked)
      end
    end

    # Convenience: call activities once (no pagination)
    def activities_all(top: 50, query: nil)
      activities(top: top, query: query)
    end

    private

    def get_json(path, params: {})
      url = build_url(@base_url, path, params)
      res = @http.get(url)
      unless res.status.success?
        raise HTTPError.new("HCCG API #{res.status}", status: res.status, body: res.to_s)
      end
      JSON.parse(res.to_s)
    end

    def build_url(base, path, params)
      uri = URI.join(base, path)
      unless params.nil? || params.empty?
        q = URI.decode_www_form(String(uri.query)) + params.compact.map { |k, v| [k.to_s, v.to_s] }
        uri.query = URI.encode_www_form(q)
      end
      uri.to_s
    end

    def slice_fallback(hash, keys)
      keys.each_with_object({}) { |k, h| h[k] = hash[k] if hash.key?(k) }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  client = HccgEventure::Client.new
  list = client.activities
  puts "Retrieved #{list.length} activities"
  list.each_with_index do |a, i|
    puts "[#{i + 1}] #{a.subject} @ #{a.activityplace} (#{a.activitysdate} ~ #{a.activityedate})"
  end

  fixtures_dir = File.expand_path('../../spec/fixtures', __FILE__)
  FileUtils.mkdir_p(fixtures_dir) unless Dir.exist?(fixtures_dir)
  out_path = File.join(fixtures_dir, 'hccg_activities_api_result.yml')
  yaml_array = list.map { |a| a.to_h.transform_keys(&:to_s) }
  File.write(out_path, YAML.dump(yaml_array))
  puts "Wrote YAML to #{out_path}"
end