# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'
require_relative '../../../../app/domain/entities/user'
require_relative '../../../../app/application/services/update_likes'

describe 'UpdateLikes Service' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_hccg

    @activities = Eventure::Hccg::ActivityMapper.new(Eventure::Hccg::Api)
                                                .find(TOP)
                                                .map(&:to_entity)

    @sample_serno = @activities.sample.serno

    @user = Eventure::Entity::User.new(
      user_id: rand(1000..9999),
      user_date: [Date.today, Date.today + 7],
      user_theme: @activities.flat_map(&:tag).sample(1),
      user_region: %w[North Central East South].sample(1),
      user_saved: [],
      user_likes: []
    )

    @service = Eventure::Services::UpdateLikes.new
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: should like an activity and return Success' do
    result = @service.call(user: @user, serno: @sample_serno)

    _(result.success?).must_equal true
    _(result.value!.user_likes).must_include @sample_serno
  end

  it 'HAPPY: should toggle like if already liked' do
    liked_user = Eventure::Entity::User.new(
      user_id: @user.user_id,
      user_date: @user.user_date,
      user_theme: @user.user_theme,
      user_region: @user.user_region,
      user_saved: @user.user_saved,
      user_likes: [@sample_serno]
    )
    result = @service.call(user: liked_user, serno: @sample_serno)

    _(result.success?).must_equal true
    _(result.value!.user_likes).wont_include @sample_serno
  end

  it 'SAD: should return failure when activity not found' do
    invalid_serno = 999_999
    result = @service.call(user: @user, serno: invalid_serno)

    _(result.failure?).must_equal true
    _(result.failure).must_equal :activity_not_found
  end
end
