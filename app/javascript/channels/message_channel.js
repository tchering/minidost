import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  const messagesContainer = document.getElementById("message-display");
  if (messagesContainer) {
    const conversation_id = messagesContainer.dataset.conversationId;
    const currentUserId = messagesContainer.dataset.currentUserId;

    //! Clean up existing subscriptions
    // Iterate through all existing ActionCable subscriptions
    consumer.subscriptions.subscriptions.forEach((subscription) => {
      // Remove the subscription from the consumer
      // This prevents duplicate subscriptions when the component re-renders
      consumer.subscriptions.remove(subscription);
    });

    //! Subscribe to the conversation channel
    consumer.subscriptions.create(
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
              <div class="message-time">
                ${new Date(data.created_at).toLocaleTimeString("en-US", {
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </div>
            </div>
          </div>
          `;
          messagesContainer.insertAdjacentHTML("beforeend", messageHtml);
          messagesContainer.scrollTop = messagesContainer.scrollHeight;
        },
      }
    );
  }
});
