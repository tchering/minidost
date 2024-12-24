import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  const notificationBadge = document.querySelectorAll(".badge-notification");
  if (notificationBadge.length > 0) {
    consumer.subscriptions.create("NotificationChannel", {
      connected() {
        console.log("connected to notification channel");
      },

      disconnected() {
        console.log("disconnected from notification channel");
      },

      received(data) {
        const badge = document.querySelector(
          `[data-conversation-id="${data.conversation_id}"] .badge-notification`
        );
        if (badge) {
          badge.textContent = data.unread_count;
        }

        const totalUnreadBadge = document.querySelector(
          ".action-button.messages .count-badge"
        );
        if (totalUnreadBadge) {
          const totalCount = parseInt(data.total_unread_count) || 0;
          totalUnreadBadge.textContent = totalCount;
          totalUnreadBadge.style.display = totalCount > 0 ? "block" : "none";
        }
      },
    });
  }
});
