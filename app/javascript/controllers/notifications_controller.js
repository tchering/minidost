import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["badge", "list", "button"]

  connect() {
    this.subscription = createConsumer().subscriptions.create("NotificationChannel", {
      received: this.handleNotification.bind(this)
    });
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  handleNotificationClick(event) {
    // Mark notification as read
    const notification = event.currentTarget;
    notification.classList.remove('unread');
    
    // Update badge count
    const unreadCount = this.listTarget.querySelectorAll('.unread').length - 1;
    if (unreadCount <= 0) {
      this.badgeTarget.remove();
    } else {
      this.badgeTarget.textContent = unreadCount;
    }
  }

  handleNotification(data) {
    const notification = data.notification;
    
    // Update badge count
    let badgeElement = this.badgeTarget;
    if (!badgeElement) {
      badgeElement = document.createElement('span');
      badgeElement.className = 'notification-badge';
      badgeElement.setAttribute('data-notifications-target', 'badge');
      this.buttonTarget.appendChild(badgeElement);
    }
    
    const currentCount = parseInt(badgeElement.textContent || '0');
    badgeElement.textContent = currentCount + 1;

    // Check for existing notification from the same sender
    const existingNotification = this.listTarget.querySelector(
      `.notification-item[data-sender-id="${notification.sender_id}"]`
    );

    const timeText = this.formatTimeAgo(new Date(notification.created_at));

    if (existingNotification) {
      // Update existing notification
      const messageCount = parseInt(existingNotification.dataset.messageCount || '1') + 1;
      existingNotification.dataset.messageCount = messageCount;
      
      // Update notification text to show message count
      const textElement = existingNotification.querySelector('.notification-text');
      textElement.textContent = `Nouveau message de ${notification.text.split(' de ')[1]}`;
      
      // Update time
      const timeElement = existingNotification.querySelector('.notification-time');
      timeElement.textContent = timeText;

      // Move to top
      this.listTarget.insertBefore(existingNotification, this.listTarget.firstChild);
    } else {
      // Add new notification
      const notificationHtml = this.buildNotificationHtml(notification, timeText);
      this.listTarget.insertAdjacentHTML('afterbegin', notificationHtml);
    }

    // Remove oldest notification if more than 10
    const notifications = this.listTarget.querySelectorAll('.notification-item');
    if (notifications.length > 10) {
      notifications[notifications.length - 1].remove();
    }
  }

  formatTimeAgo(date) {
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);
    
    if (diffInSeconds < 60) {
      return 'just now';
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60);
      return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600);
      return `about ${hours} hour${hours > 1 ? 's' : ''} ago`;
    } else {
      const days = Math.floor(diffInSeconds / 86400);
      return `${days} day${days > 1 ? 's' : ''} ago`;
    }
  }

  buildNotificationHtml(notification, timeText) {
    return `
      <a href="${notification.path}" 
         class="dropdown-item notification-item unread" 
         data-turbo-method="patch"
         data-action="click->notifications#handleNotificationClick"
         data-notification-id="${notification.id}"
         data-sender-id="${notification.sender_id || ''}"
         data-conversation-id="${notification.conversation_id || ''}">
        <div class="d-flex align-items-center">
          <div class="me-2">
            ${this.getNotificationIcon(notification)}
          </div>
          <div class="notification-content flex-grow-1">
            <p class="notification-text mb-1">${notification.text}</p>
            <small class="text-muted">${timeText}</small>
          </div>
        </div>
      </a>
    `;
  }

  getNotificationIcon(notification) {
    switch(notification.notifiable_type) {
      case 'Message':
        return '<i class="fas fa-envelope"></i>';
      case 'TaskApplication':
        return '<i class="fas fa-file-alt"></i>';
      case 'Contract':
        return notification.action === 'sign_required' ? 
          '<i class="fas fa-file-signature"></i>' : 
          '<i class="fas fa-file-contract"></i>';
      default:
        return '<i class="fas fa-bell"></i>';
    }
  }
}
