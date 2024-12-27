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
    // Update unread count
    const currentCount = parseInt(this.element.dataset.unreadCount || "0");
    const newCount = currentCount + 1;
    
    this.element.dataset.unreadCount = newCount;
    
    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = newCount;
      this.badgeTarget.style.display = newCount > 0 ? "block" : "none";
    }

    // Update last message preview
    const messagePreview = this.element.querySelector(".text-muted.text-truncate");
    if (messagePreview) {
      messagePreview.textContent = data.content;
    }
  }
}
