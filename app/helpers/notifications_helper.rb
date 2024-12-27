module NotificationsHelper
  include ActionView::Helpers::TranslationHelper
  include AbstractController::Translation

  def notification_icon(notification)
    case notification.notifiable_type
    when "Message"
      content_tag(:i, "", class: "fas fa-envelope")
    when "TaskApplication"
      content_tag(:i, "", class: "fas fa-file-alt")
    when "Contract"
      if notification.action == "sign_required"
        content_tag(:i, "", class: "fas fa-file-signature")
      else
        content_tag(:i, "", class: "fas fa-file-contract")
      end
    else
      content_tag(:i, "", class: "fas fa-bell")
    end
  end

  def notification_text(notification)
    return I18n.t('notifications.default') unless notification.notifiable

    case notification.notifiable_type
    when "Message"
      handle_message_notification(notification)
    when "TaskApplication"
      handle_task_application_notification(notification)
    when "Contract"
      handle_contract_notification(notification)
    else
      I18n.t('notifications.default')
    end
  end

  private

  def handle_message_notification(notification)
    message = notification.notifiable
    return I18n.t('notifications.messages.new_message', sender: message.sender.first_name) unless message.conversation

    unread_count = message.conversation.messages
                         .where(sender: message.sender)
                         .where('created_at >= ?', notification.created_at)
                         .count
    
    if unread_count > 1
      I18n.t('notifications.messages.new_messages', count: unread_count, sender: message.sender.first_name)
    else
      I18n.t('notifications.messages.new_message', sender: message.sender.first_name)
    end
  end

  def handle_task_application_notification(notification)
    application = notification.notifiable
    return I18n.t('notifications.task_applications.new_application_default') unless application&.task

    I18n.t('notifications.task_applications.new_application', 
      site: application.task.site_name, 
      city: application.task.city)
  end

  def handle_contract_notification(notification)
    contract = notification.notifiable
    return I18n.t('notifications.contracts.default') unless contract&.task

    if notification.action == "sign_required"
      I18n.t('notifications.contracts.sign_required', 
        site: contract.task.site_name, 
        city: contract.task.city)
    else
      # Determine who signed based on the notification recipient
      signer = notification.recipient == contract.contractor ? contract.subcontractor : contract.contractor
      I18n.t('notifications.contracts.signed', 
        user: signer.first_name)
    end
  end
end
