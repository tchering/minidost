import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  // Check for any notification-related elements
  if (document.querySelector(".badge-notification") || 
      document.querySelector(".action-button.messages") ||
      document.querySelector(".quick-actions")) {
    
    consumer.subscriptions.create("NotificationChannel", {
      connected() {
        console.log("connected to notification channel");
      },

      disconnected() {
        console.log("disconnected from notification channel");
      },

      received(data) {
        // Update conversation badge if it exists
        const badge = document.querySelector(
          `[data-conversation-id="${data.conversation_id}"] .badge-notification`
        );
        if (badge) {
          badge.textContent = "new";
          badge.style.display = "block";
        }

        // Update message badges in the task status to show 'new'
        const messageBadges = document.querySelectorAll(".action-button.messages .count-badge");
        messageBadges.forEach(badge => {
          badge.textContent = "new";
          badge.style.display = "inline";
        });

        // Update dashboard notification badge to show count
        const dashboardBadge = document.querySelector(".notifications-dropdown .notification-badge");
        if (dashboardBadge) {
          const currentCount = parseInt(dashboardBadge.textContent || "0");
          dashboardBadge.textContent = currentCount + 1;
          dashboardBadge.style.display = "inline";
        }

        // Trigger a Turbo frame refresh for real-time updates if frames exist
        const conversationFrame = document.querySelector("#conversation_frame");
        if (conversationFrame) {
          conversationFrame.reload();
        }
      },
    });
  }
});
