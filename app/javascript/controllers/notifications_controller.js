import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["badge", "list", "button", "messageCount"]

  connect() {
    this.subscription = createConsumer().subscriptions.create("NotificationChannel", {
      received: this.handleNotification.bind(this)
    });

    // Initialize message counts
    this.updateMessageCounts();
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  updateMessageCounts() {
    const conversationElements = document.querySelectorAll('[data-conversation-id]');
    conversationElements.forEach(element => {
      const conversationId = element.dataset.conversationId;
      const unreadCount = element.dataset.unreadCount || 0;
      const badge = element.querySelector('.badge-notification');
      if (badge) {
        badge.textContent = unreadCount;
        badge.style.display = unreadCount > 0 ? 'block' : 'none';
      }
    });
  }

  handleNotification(data) {
    const notification = data.notification;
    
    // Check for existing notification from same sender in same conversation
    const existingNotification = this.listTarget.querySelector(
      `[data-sender-id="${notification.sender_id}"][data-conversation-id="${notification.conversation_id}"]`
    );

    // Format the time using the browser's locale
    const timeText = this.formatTimeAgo(new Date(notification.created_at));

    if (existingNotification) {
      // Update existing notification
      const textElement = existingNotification.querySelector('.notification-text');
      textElement.textContent = notification.text;
      const timeElement = existingNotification.querySelector('.text-muted');
      timeElement.textContent = timeText;
    } else {
      // Add new notification
      const notificationHtml = this.buildNotificationHtml(notification, timeText);
      this.listTarget.insertAdjacentHTML("afterbegin", notificationHtml);

      // Update badge count
      const currentCount = parseInt(this.badgeTarget.textContent || "0");
      this.badgeTarget.textContent = currentCount + 1;
      this.badgeTarget.style.display = "flex";

      // Remove "No notifications" message if it exists
      const emptyMessage = this.listTarget.querySelector(".no-notifications");
      if (emptyMessage) {
        emptyMessage.remove();
      }
    }

    // Update message counts in conversations list
    if (notification.notifiable_type === "Message") {
      this.updateMessageCounts();
    }
  }

  formatTimeAgo(date) {
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);

    if (diffInSeconds < 60) {
      return I18n.t('datetime.distance_in_words.less_than_x_minutes', { count: 1 });
    } else if (diffInSeconds < 3600) {
      const minutes = Math.floor(diffInSeconds / 60);
      return I18n.t('datetime.distance_in_words.x_minutes', { count: minutes });
    } else if (diffInSeconds < 86400) {
      const hours = Math.floor(diffInSeconds / 3600);
      return I18n.t('datetime.distance_in_words.about_x_hours', { count: hours });
    } else {
      const days = Math.floor(diffInSeconds / 86400);
      return I18n.t('datetime.distance_in_words.x_days', { count: days });
    }
  }

  buildNotificationHtml(notification, timeText) {
    return `
      <a href="${notification.path}" 
         class="dropdown-item notification-item unread" 
         data-turbo-method="patch"
         data-sender-id="${notification.sender_id}"
         data-conversation-id="${notification.conversation_id}">
        <div class="d-flex align-items-center">
          <div class="notification-icon me-3">
            <i class="${this.getNotificationIcon(notification)}"></i>
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
    const icons = {
      Message: "fas fa-envelope",
      TaskApplication: "fas fa-file-alt",
      Contract: notification.action === "sign_required" ? 
        "fas fa-file-signature" : "fas fa-file-contract"
    }
    return icons[notification.notifiable_type] || "fas fa-bell"
  }
}
