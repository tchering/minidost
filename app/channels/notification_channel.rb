class NotificationChannel < ApplicationCable::Channel
  include NotificationsHelper

  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  def self.broadcast_notification(notification)
    helper = Class.new do
      include NotificationsHelper
      include ActionView::Helpers::TranslationHelper
      include AbstractController::Translation
    end.new

    broadcast_to(
      notification.recipient,
      {
        notification: {
          id: notification.id,
          notifiable_type: notification.notifiable_type,
          action: notification.action,
          text: helper.notification_text(notification),
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
    locale_param = { locale: I18n.locale }

    case notification.notifiable_type
    when "Message"
      conversation = notification.notifiable.conversation
      helpers.chat_conversation_path(id: conversation.id, **locale_param)
    when "TaskApplication"
      task = notification.notifiable.task
      helpers.task_task_applications_path(task_id: task.id, **locale_param)
    when "Contract"
      task = notification.notifiable.task
      contract = notification.notifiable
      helpers.task_contract_path(task_id: task.id, id: contract.id, **locale_param)
    else
      helpers.notifications_path(**locale_param)
    end
  rescue => e
    Rails.logger.error "Failed to generate notification path: #{e.message}"
    helpers.notifications_path(**locale_param)
  end
end
