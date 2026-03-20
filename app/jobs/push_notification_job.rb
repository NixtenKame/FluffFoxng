# frozen_string_literal: true

class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(dmail_id)
    dmail = Dmail.find_by(id: dmail_id)
    return if dmail.nil?

    PushNotifications.send_dmail(dmail)
  end
end
