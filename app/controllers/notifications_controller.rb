class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [:update]

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def update
    @notification.update(read_at: Time.current) unless @notification.read_at
    
    path = case @notification.notifiable_type
    when "Message"
      chat_conversation_path(@notification.notifiable.conversation, locale: I18n.locale)
    when "TaskApplication"
      task_path(@notification.notifiable.task, locale: I18n.locale)
    when "Contract"
      task_contract_path(@notification.notifiable.task, @notification.notifiable, locale: I18n.locale)
    else
      root_path(locale: I18n.locale)
    end
    
    redirect_to path
  end

  def mark_all_as_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back(fallback_location: root_path)
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end
end
