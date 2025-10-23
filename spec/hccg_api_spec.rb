# frozen_string_literal: true

require_relative 'helper/spec_helper'
require_relative 'helper/vcr_helper'
require_relative '../app/models/gateways/hccg_api'

describe 'Tests hccg activity API library' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_hccg
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Error raising' do
    it 'SAD: should raise exception on invalid top argument' do
      error = _(
        proc {
          @data = Eventure::Hccg::ActivityMapper
                 .new(Eventure::Hccg::Api)
                 .find(101)
        }
      ).must_raise RuntimeError
      _(error.message).must_equal 'Request Failed'
    end
  end

  describe 'Data content and structure' do
    before do
      @data = Eventure::Hccg::ActivityMapper.new(Eventure::Hccg::Api).find(TOP)
    end

    it 'HAPPY: should provide correct pubunitname' do
      idx = rand(@data.length)
      _(@data[idx].publish_unit).must_equal CORRECT[idx]['pubunitname']
    end

    it 'HAPPY: should provide correct subject' do
      idx = rand(@data.length)
      _(@data[idx].subject).wont_be_nil
      _(@data[idx].subject).must_equal CORRECT[idx]['subject']
    end

    it 'HAPPY: should provide correct detailcontent' do
      idx = rand(@data.length)
      _(@data[idx].details).must_equal CORRECT[idx]['detailcontent']
    end

    it 'HAPPY: should provide correct classes' do
      idx = rand(@data.length)
      _(@data[idx].subject_class).must_be_kind_of Array
      _(@data[idx].service_class).must_equal(CORRECT[idx]['serviceclass'].split(',').map do |item|
        item.split(']')[1]
      end)
    end

    it 'HAPPY: should provide correct voice' do
      idx = rand(@data.length)
      _(@data[idx].voice).must_equal CORRECT[idx]['voice']
    end

    it 'HAPPY: should provide correct unit' do
      idx = rand(@data.length)
      _(@data[idx].host).wont_be_nil
      _(@data[idx].host).must_equal CORRECT[idx]['hostunit']
    end

    it 'HAPPY: should provide correct date' do
      idx = rand(@data.length)
      _(@data[idx].start_time).must_be_kind_of DateTime
      _(@data[idx].end_time).must_be :>=, @data[idx].start_time
    end

    it 'HAPPY: should provide correct place' do
      idx = rand(@data.length)
      _(@data[idx].place).must_equal CORRECT[idx]['activityplace']
    end

    it 'HAPPY: should provide correct number of data' do
      _(@data.length).must_equal TOP
    end
  end
end
