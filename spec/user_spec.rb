# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'
require_relative '../app/domain/entities/user'
require_relative '../app/domain/values/saved'
require_relative '../app/domain/values/filter'

describe 'User entity domain logic tests' do
  VcrHelper.setup_vcr

  before do 
    VcrHelper.configure_vcr_for_hccg
    @activities = Eventure::Hccg::ActivityMapper.new(Eventure::Hccg::Api)
                                                .find(TOP)
                                                .map(&:to_entity)

    @available_tags = @activities.flat_map(&:tag).uniq
    @available_regions = ['North', 'Central', 'East', 'South']

    @base_user = Eventure::Entity::User.new(
      user_id: rand(1000..9999).to_s,
      user_date: Date.today,
      user_theme: @available_tags.sample,
      user_region: @available_regions.sample,
      user_saved: [],
      user_likes: []
    )
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'User entity structure' do 
    it 'HAPPY: should create a user entity with correct datatype' do 
      _(@base_user).must_be_kind_of Eventure::Entity::User
      _(@base_user.user_id).must_be_kind_of String
      _(@base_user.user_date).must_be_kind_of Date
    end

    it 'HAPPY: should initialize with empty collections' do
      _(@base_user.saved_count).must_equal 0
      _(@base_user.likes_count).must_equal 0
      _(@base_user.saved_activities).must_be_kind_of Array
    end
  end

  describe 'User preference methods' do
    it 'HAPPY: should set start date' do
      new_date = Date.today + 7
      updated_user = @base_user.set_start_date(new_date)

      _(updated_user.user_date).must_equal new_date
    end

    it 'HAPPY: should add and remove theme' do 
      user_no_theme = @base_user.remove_theme
      theme = @available_tags.sample
      updated_user = user_no_theme.add_theme(theme)

      _(updated_user.user_theme).must_equal theme
      _(updated_user.remove_theme.user_theme).must_be_nil
    end

    it 'HAPPY: should add and remove region' do 
      user_no_region = @base_user.remove_region
      region = @available_regions.sample
      updated_user = user_no_region.add_region(region)

      _(updated_user.user_region).must_equal region
      _(updated_user.remove_region.user_region).must_be_nil
    end
  end

  describe 'Saved activities logic' do
    let(:sample_serno) { @activities[rand(@activities.length)].serno }
    let(:another_serno) { @activities[(@activities.length - 1)].serno }

    it 'HAPPY: should add saved activity' do 
      updated_user = @base_user.add_saved(sample_serno)

      _(updated_user.user_saved.length).must_equal 1
      _(updated_user.user_saved).must_include sample_serno
    end

    it 'HAPPY: should add multiple saved activities' do
      updated_user = @base_user.add_saved(sample_serno).add_saved(another_serno)

      _(updated_user.user_saved.length).must_equal 2
      _(updated_user.user_saved).must_include sample_serno
      _(updated_user.user_saved).must_include another_serno
    end

    it 'HAPPY: should not duplicate saved activities' do
      updated_user = @base_user.add_saved(sample_serno).add_saved(sample_serno)

      _(updated_user.user_saved.length).must_equal 1
    end

    it 'HAPPY: should remove saved activity' do
      updated_user = @base_user.add_saved(sample_serno).remove_saved(sample_serno)

      _(updated_user.user_saved).must_be_empty
      _(updated_user.user_saved).wont_include sample_serno
    end

    it 'HAPPY: should maintain immutability when adding saved activity' do
      original_count = @base_user.user_saved.length
      _updated_user = @base_user.add_saved(sample_serno)

      _(@base_user.user_saved.length).must_equal original_count
    end
  end

  describe 'User likes activities logic' do
    let(:sample_serno) { @activities[rand(@activities.length)].serno }

    it 'HAPPY: should add liked activity' do 
      updated_user = @base_user.add_user_likes(sample_serno)

      _(updated_user.user_likes.length).must_equal 1
      _(updated_user.user_likes).must_include sample_serno
    end

    it 'HAPPY: should not duplicate liked activities' do
      updated_user = @base_user.add_user_likes(sample_serno).add_user_likes(sample_serno)

      _(updated_user.user_likes.length).must_equal 1
    end

    it 'HAPPY: should remove liked activity' do
      updated_user = @base_user.add_user_likes(sample_serno).remove_user_likes(sample_serno)

      _(updated_user.user_likes).must_be_empty
      _(updated_user.user_likes).wont_include sample_serno
    end
  end

  describe 'User to filter conversion' do
    it 'HAPPY: should convert user preferences to filter value object' do
      filter = @base_user.to_filter

      _(filter).must_be_kind_of Eventure::Value::Filter
      _(filter.filter_date).must_equal @base_user.user_date
      _(filter.filter_theme).must_equal @base_user.user_theme
      _(filter.filter_region).must_equal @base_user.user_region
    end
  end

  describe 'User to saved conversion' do
    it 'HAPPY: should convert user to saved value object when has saved items' do
      serno = @activities[rand(@activities.length)].serno
      updated_user = @base_user.add_saved(serno)

      saved = updated_user.to_saved

      _(saved).must_be_kind_of Eventure::Value::Saved
      _(saved.is_saved?).must_equal true
    end

    it 'HAPPY: should convert user to saved value object when no saved items' do
      saved = @base_user.to_saved

      _(saved).must_be_kind_of Eventure::Value::Saved
      _(saved.is_saved?).must_equal false
    end
  end
end