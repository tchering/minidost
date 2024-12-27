import consumer from "channels/consumer";

// Keep track of active subscription
let activeSubscription = null;

document.addEventListener("turbo:load", () => {
  const messagesContainer = document.getElementById("message-display");
  
  // Clean up existing subscription if it exists
  if (activeSubscription) {
    consumer.subscriptions.remove(activeSubscription);
    activeSubscription = null;
  }

  if (messagesContainer) {
    const conversation_id = messagesContainer.dataset.conversationId; //received from view chat.html.erb
    const currentUserId = messagesContainer.dataset.currentUserId; //received from view chat.html.erb

    //! Clean up existing subscriptions
    // Iterate through all existing ActionCable subscriptions
    consumer.subscriptions.subscriptions.forEach((subscription) => {
      // Remove the subscription from the consumer
      // This prevents duplicate subscriptions when the component re-renders
      consumer.subscriptions.remove(subscription);
    });

    //! Subscribe to the conversation channel
    activeSubscription = consumer.subscriptions.create(
      {
        channel: "MessageChannel",
        conversation_id: conversation_id, //received from view chat.html.erb sent to message_channel.rb
      },
      {
        connected() {
          console.log("Connected to the conversation channel");
        },

        disconnected() {
          console.log("Disconnected from the conversation channel");
        },

        received(data) {
          const messageHtml = `
          <div class="message-wrapper ${
            data.user_id == currentUserId ? "sent" : "received"
          }">
            <div class="message">
              <div class="message-sender">
                ${data.sender.first_name}
              </div>
              <div class="message-bubble ${data.read ? "" : "unread"}">
                ${data.content}
              </div>
              <div class="message-timestamp">
                ${new Date().toLocaleTimeString()}
              </div>
            </div>
          </div>
          `;

          messagesContainer.insertAdjacentHTML("beforeend", messageHtml);
          messagesContainer.scrollTop = messagesContainer.scrollHeight;

          // Update badges to show "new"
          const conversationBadges = document.querySelectorAll('.badge-notification');
          conversationBadges.forEach(badge => {
            if (badge.closest(`[data-conversation-id="${conversation_id}"]`)) {
              badge.textContent = "new";
              badge.style.display = "block";
            }
          });

          // Update task status badge
          const taskStatusBadge = document.querySelector('.action-button.messages .count-badge');
          if (taskStatusBadge) {
            taskStatusBadge.textContent = "new";
            taskStatusBadge.style.display = "inline";
          }
        },
      }
    );
  }
});

// Clean up on page unload
document.addEventListener("turbo:before-cache", () => {
  if (activeSubscription) {
    consumer.subscriptions.remove(activeSubscription);
    activeSubscription = null;
  }
});
