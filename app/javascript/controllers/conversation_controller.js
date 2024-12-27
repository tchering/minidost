import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["badge"]

  connect() {
    const conversationId = this.element.dataset.conversationId;
    if (!conversationId) return;

    this.subscription = createConsumer().subscriptions.create(
      { 
        channel: "MessageChannel",
        conversation_id: conversationId
      },
      {
        received: this.handleMessage.bind(this)
      }
    );
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe();
    }
  }

  handleMessage(data) {
    // Update unread count in dataset
    const currentCount = parseInt(this.element.dataset.unreadCount || "0");
    const newCount = currentCount + 1;
    this.element.dataset.unreadCount = newCount;
    
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = "new";
      this.badgeTarget.style.display = "block";
    }

    // Update last message preview if it exists
    const messagePreview = this.element.querySelector(".text-muted.text-truncate");
    if (messagePreview) {
      messagePreview.textContent = data.content;
    }

    // Update the global message badge in task status
    const taskStatusBadge = document.querySelector('.action-button.messages .count-badge');
    if (taskStatusBadge) {
      taskStatusBadge.textContent = "new";
      taskStatusBadge.style.display = "inline";
    }
  }
}
