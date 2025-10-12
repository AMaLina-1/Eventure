# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/hccg/hccg_activity'

TOP = 10
CORRECT = YAML.safe_load_file('spec/fixtures/results.yml')

describe 'Tests hccg activity API library' do
  describe 'Error raising' do
    it 'SAD: should raise exception on invalid top argument' do
      error = _(proc { @data = Eventure::ActivityExport.new.run(top: 101) }).must_raise RuntimeError
      _(error.message).must_equal 'Request Failed'
    end
  end

  describe 'Data content and structure' do
    before do
      @data = Eventure::ActivityExport.new.run(top: TOP)
    end

    it 'HAPPY: should provide correct pubunitname' do
      idx = rand(@data.length)
      _(@data[idx].pubunitname).must_equal CORRECT[idx]['pubunitname']
    end

    it 'HAPPY: should provide correct subject' do
      idx = rand(@data.length)
      _(@data[idx].subject).wont_be_nil
      _(@data[idx].subject).must_equal CORRECT[idx]['subject']
    end

    it 'HAPPY: should provide correct detailcontent' do
      idx = rand(@data.length)
      _(@data[idx].detailcontent).must_equal CORRECT[idx]['detailcontent']
    end

    it 'HAPPY: should provide correct classes' do
      idx = rand(@data.length)
      _(@data[idx].subjectclass).must_match(/\[[A-Za-z0-9]+\].+/)
      _(@data[idx].serviceclass).must_match(/\[[A-Za-z0-9]+\].+/)
    end

    it 'HAPPY: should provide correct voice' do
      idx = rand(@data.length)
      _(@data[idx].voice).must_equal CORRECT[idx]['voice']
    end

    it 'HAPPY: should provide correct unit' do
      idx = rand(@data.length)
      _(@data[idx].hostunit).wont_be_nil
      _(@data[idx].hostunit).must_equal CORRECT[idx]['hostunit']
    end

    it 'HAPPY: should provide correct date' do
      idx = rand(@data.length)
      _(@data[idx].activitysdate).must_be_kind_of String
      _(@data[idx].activitysdate).must_equal CORRECT[idx]['activitysdate']
      _(@data[idx].activityedate).must_equal CORRECT[idx]['activityedate']
      _(@data[idx].activityedate).must_be :>=, @data[idx].activitysdate
    end

    it 'HAPPY: should provide correct place' do
      idx = rand(@data.length)
      _(@data[idx].activityplace).must_equal CORRECT[idx]['activityplace']
    end

    it 'HAPPY: should provide correct number of data' do
      _(@data.length).must_equal TOP
    end
  end
end
