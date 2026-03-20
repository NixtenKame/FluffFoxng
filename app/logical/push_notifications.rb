# frozen_string_literal: true

module PushNotifications
  module_function

  def send_dmail(dmail)
    return unless Danbooru.config.enable_push_notifications?
    return unless dmail.owner_id == dmail.to_id
    return if dmail.is_deleted? || dmail.is_read?
    return if dmail.to.dmail_filter&.filtered?(dmail)

    payload = {
      title: "#{Danbooru.config.app_name} - New DMail",
      body: "#{dmail.from.pretty_name}: #{dmail.title}",
      icon: "/android-chrome-192x192.png",
      badge: "/favicon-32x32.png",
      tag: "dmail-#{dmail.id}",
      data: {
        url: Rails.application.routes.url_helpers.dmail_url(dmail, host: Danbooru.config.hostname, protocol: "https")
      }
    }

    PushSubscription.where(user_id: dmail.to_id).find_each do |subscription|
      send_payload(subscription, payload)
    end
  end

  def send_payload(subscription, payload)
    Webpush.payload_send(
      message: JSON.generate(payload),
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: Danbooru.config.vapid_subject,
        public_key: Danbooru.config.vapid_public_key,
        private_key: Danbooru.config.vapid_private_key
      }
    )
  rescue Webpush::InvalidSubscription, Webpush::ExpiredSubscription => e
    subscription.destroy
    DanbooruLogger.log(e, expected: true)
  rescue Webpush::ResponseError => e
    status = e.response&.code.to_i
    if [404, 410].include?(status)
      subscription.destroy
      DanbooruLogger.log(e, expected: true)
    else
      DanbooruLogger.log(e)
    end
  rescue StandardError => e
    DanbooruLogger.log(e)
  end
end
