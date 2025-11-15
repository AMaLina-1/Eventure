# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require_relative '../../../app/domain/entities/user'
require_relative '../../../app/domain/values/saved'
require_relative '../../../app/domain/values/filter'

describe 'User entity domain logic tests' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_hccg
    @activities = Eventure::Hccg::ActivityMapper.new(Eventure::Hccg::Api)
                                                .find(TOP)
                                                .map(&:to_entity)

    @available_tags = @activities.flat_map(&:tag).uniq
    @available_regions = %w[North Central East South]

    @base_user = Eventure::Entity::User.new(
      user_id: rand(1000..9999),
      user_date: [Date.today, Date.today + 7],
      user_theme: [@available_tags.sample],
      user_region: [@available_regions.sample],
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
      _(@base_user.user_id).must_be_kind_of Integer
      _(@base_user.user_date).must_be_kind_of Array
      _(@base_user.user_date.all? { |date| date.is_a?(Date) }).must_equal true
    end

    it 'HAPPY: should initialize with empty collections' do
      _(@base_user.user_saved.length).must_equal 0
      _(@base_user.user_likes.length).must_equal 0
      _(@base_user.user_saved).must_be_kind_of Array
    end
  end

  describe 'User preference methods' do
    it 'HAPPY: should update start and end dates' do
      new_start = Date.today + 1
      new_end = Date.today + 10

      updated_user = @base_user.update_start_date(new_start).update_end_date(new_end)

      _(updated_user.user_date[0]).must_equal new_start
      _(updated_user.user_date[1]).must_equal new_end
    end

    it 'HAPPY: should add and remove multiple theme' do
      theme1 = @available_tags.sample
      theme2 = @available_tags.sample
      updated_user = @base_user.add_theme(theme1).add_theme(theme2)

      _(updated_user.user_theme).must_include theme1
      _(updated_user.user_theme).must_include theme2

      removed_user = updated_user.remove_theme(theme1)
      _(removed_user.user_theme).wont_include theme1
    end

    it 'HAPPY: should add and remove multiple regions' do
      region1 = @available_regions.sample
      region2 = @available_regions.sample
      updated_user = @base_user.add_region(region1).add_region(region2)

      _(updated_user.user_region).must_include region1
      _(updated_user.user_region).must_include region2

      removed_user = updated_user.remove_region(region1)
      _(removed_user.user_region).wont_include region1
    end
  end

  describe 'Saved activities logic' do
    let(:sample_serno) { @activities[rand(@activities.length)].serno }
    let(:another_serno) do
      other = @activities.reject { |act| act.serno == sample_serno }.sample
      other.serno
    end

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
      _(saved.saved?(serno)).must_equal true
    end

    it 'HAPPY: should convert user to saved value object when no saved items' do
      saved = @base_user.to_saved

      _(saved).must_be_kind_of Eventure::Value::Saved
      _(saved.saved?('any_id')).must_equal false
    end
  end
end
