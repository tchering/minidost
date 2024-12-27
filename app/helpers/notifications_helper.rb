module NotificationsHelper
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
    case notification.notifiable_type
    when "Message"
      message = notification.notifiable
      unread_count = message.conversation.messages
                           .where(sender: message.sender)
                           .where('created_at >= ?', notification.created_at)
                           .count
      
      if unread_count > 1
        "#{unread_count} new messages from #{message.sender.first_name}"
      else
        "New message from #{message.sender.first_name}"
      end
    when "TaskApplication"
      task = notification.notifiable.task
      "New application for task in #{task.site_name}, #{task.city}"
    when "Contract"
      task = notification.notifiable.task
      if notification.action == "sign_required"
        "Contract ready for signature: #{task.site_name}, #{task.city}"
      else
        "#{notification.notifiable.user.first_name} has signed the contract"
      end
    else
      "New notification"
    end
  end
end
