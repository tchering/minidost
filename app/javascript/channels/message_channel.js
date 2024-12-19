import consumer from "./consumer"

const initializeMessageChannel = () => {
  const element = document.getElementById("messages-container")
  if (!element) return

  const recipientId = element.getAttribute("data-recipient-id")
  const currentUserId = element.getAttribute("data-current-user")

  consumer.subscriptions.create(
    {
      channel: "MessageChannel",
      recipient_id: recipientId,
      current_user_id: currentUserId
    },
    {
      connected() {
        console.log("Connected to MessageChannel")
      },
      
      received(data) {
        const messageClass = parseInt(data.sender_id) === parseInt(currentUserId) ? "sent" : "received"
        this.appendMessage(data, messageClass)
      },
      
      appendMessage(data, messageClass) {
        const messagesContainer = document.getElementById("messages")
        if (!messagesContainer) return
        
        const messageHtml = `
          <div class="message-wrapper ${messageClass}">
            <div class="message-bubble">
              <div class="message-content">${data.content}</div>
              <div class="message-time">${data.created_at}</div>
            </div>
          </div>
        `
        messagesContainer.insertAdjacentHTML("beforeend", messageHtml)
        messagesContainer.scrollTop = messagesContainer.scrollHeight
      }
    }
  )
}

// Use both event listeners to ensure the code runs in all scenarios
document.addEventListener("turbo:load", initializeMessageChannel)
document.addEventListener("DOMContentLoaded", initializeMessageChannel)
