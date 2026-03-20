# frozen_string_literal: true

class PushSubscriptionsController < ApplicationController
  include JsonResponseHelper

  before_action :member_only
  respond_to :json
  skip_before_action :api_check

  def create
    unless Danbooru.config.enable_push_notifications?
      render_expected_error(503, "Push notifications are disabled")
      return
    end

    subscription = subscription_params
    record = PushSubscription.find_or_initialize_by(user: CurrentUser.user, endpoint: subscription[:endpoint])
    record.assign_attributes(
      p256dh_key: subscription.dig(:keys, :p256dh),
      auth_key: subscription.dig(:keys, :auth),
      expiration_time: subscription[:expiration_time],
      user_agent: request.user_agent
    )
    record.save!

    render json: { id: record.id }
  rescue ActiveRecord::RecordInvalid => e
    render_expected_error(422, e.record.errors.full_messages.join(", "))
  end

  def destroy
    unless Danbooru.config.enable_push_notifications?
      render_expected_error(503, "Push notifications are disabled")
      return
    end

    endpoint = params[:endpoint].to_s
    if endpoint.blank?
      render_expected_error(422, "endpoint is required")
      return
    end

    PushSubscription.find_by(user: CurrentUser.user, endpoint: endpoint)&.destroy
    render json: { ok: true }
  end

  private

  def subscription_params
    params.require(:subscription).permit(:endpoint, :expiration_time, keys: %i[p256dh auth])
  end
end
