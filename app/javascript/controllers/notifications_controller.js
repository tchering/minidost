import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["badge", "list", "button", "item"]

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
    const notification = event.currentTarget;
    
    // Remove the notification item from the list
    notification.classList.add('fade-out');
    setTimeout(() => {
      notification.remove();
      this.updateNotificationCount();
      this.checkEmptyState();
    }, 300); // Match this with CSS transition duration
  }

  updateNotificationCount() {
    const unreadCount = this.listTarget.querySelectorAll('.unread').length;
    if (unreadCount <= 0) {
      this.badgeTarget?.remove();
    } else if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = unreadCount;
    }
  }

  checkEmptyState() {
    const hasNotifications = this.listTarget.querySelectorAll('.notification-item').length > 0;
    if (!hasNotifications) {
      const emptyState = document.createElement('div');
      emptyState.className = 'text-center p-3 text-muted';
      emptyState.innerHTML = '<small>No notifications</small>';
      this.listTarget.appendChild(emptyState);
    }
  }

  handleNotification(data) {
    const notification = data.notification;
    
    // Update badge count
    let badgeElement = this.hasBadgeTarget ? this.badgeTarget : null;
    if (!badgeElement) {
      badgeElement = document.createElement('span');
      badgeElement.className = 'notification-badge';
      badgeElement.setAttribute('data-notifications-target', 'badge');
      this.buttonTarget.appendChild(badgeElement);
    }
    
    const currentCount = parseInt(badgeElement.textContent || '0');
    badgeElement.textContent = currentCount + 1;

    // Remove empty state if it exists
    const emptyState = this.listTarget.querySelector('.text-muted');
    if (emptyState) {
      emptyState.remove();
    }

    // Check for existing notification from the same sender
    const existingNotification = this.listTarget.querySelector(
      `.notification-item[data-sender-id="${notification.sender_id}"]`
    );

    if (existingNotification) {
      existingNotification.outerHTML = this.buildNotificationHtml(notification, this.formatTimeAgo(new Date(notification.created_at)));
    } else {
      this.listTarget.insertAdjacentHTML('afterbegin', 
        this.buildNotificationHtml(notification, this.formatTimeAgo(new Date(notification.created_at)))
      );
    }
  }

  formatTimeAgo(date) {
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);
    const diffInMinutes = Math.floor(diffInSeconds / 60);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);

    if (diffInSeconds < 60) return "just now";
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
    if (diffInHours < 24) return `${diffInHours}h ago`;
    if (diffInDays === 1) return "yesterday";
    return `${diffInDays}d ago`;
  }

  buildNotificationHtml(notification, timeText) {
    return `
      <a href="${notification.path}" 
         class="dropdown-item notification-item unread" 
         data-notification-id="${notification.id}"
         data-sender-id="${notification.sender_id}"
         data-action="click->notifications#handleNotificationClick"
         data-turbo-method="patch">
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
    const iconMap = {
      'Message': '<i class="fas fa-envelope"></i>',
      'TaskApplication': '<i class="fas fa-file-alt"></i>',
      'Contract': '<i class="fas fa-file-contract"></i>',
      'Task': '<i class="fas fa-clipboard-list"></i>'
    };
    return iconMap[notification.notifiable_type] || '<i class="fas fa-bell"></i>';
  }
}
