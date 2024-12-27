class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  def self.broadcast_notification(notification)
    broadcast_to(
      notification.recipient,
      {
        notification: {
          id: notification.id,
          notifiable_type: notification.notifiable_type,
          action: notification.action,
          text: NotificationsHelper.instance_method(:notification_text)
                                 .bind(Class.new { include NotificationsHelper }.new)
                                 .call(notification),
          path: generate_notification_path(notification),
          created_at: notification.created_at,
          sender_id: notification.sender_id,
          conversation_id: notification.conversation_id
        }
      }
    )
  end

  private

  def self.generate_notification_path(notification)
    helpers = Rails.application.routes.url_helpers
    case notification.notifiable_type
    when "Message"
      helpers.chat_conversation_path(notification.notifiable.conversation, locale: I18n.locale)
    when "TaskApplication"
      helpers.task_path(notification.notifiable.task, locale: I18n.locale)
    when "Contract"
      helpers.task_contract_path(notification.notifiable.task, notification.notifiable, locale: I18n.locale)
    else
      helpers.notifications_path(locale: I18n.locale)
    end
  end
end
