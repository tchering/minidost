class MessagesController < ApplicationController
  before_action :set_conversation, only: [:create]

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user

    respond_to do |format|
      if @message.save
        # Single broadcast with all necessary data
        broadcast_data = @message.as_json(include: { sender: { only: [:id, :first_name] } })
        broadcast_data[:user_id] = current_user.id

        ActionCable.server.broadcast(
          "conversation_#{@conversation.id}",
          broadcast_data
        )

        format.html { redirect_to chat_conversation_path(@conversation, locale: I18n.locale) }
      else
        format.html { redirect_to chat_conversation_path(@conversation, locale: I18n.locale),
                      status: :unprocessable_entity,
                      alert: "Message failed to send" }
      end
    end
  end

  def mark_as_read
    @conversation = current_user.conversations.find(params[:conversation_id])

    notifications = Notification.where(
      notifiable_type: "Message",
      notifiable_id: @conversation.messages.pluck(:id),
      recipient: current_user,
      read_at: nil,
    )

    #! Update read_at timestamp
    notifications.update_all(read_at: Time.current)

    #! Delete read notifications - fix order of operations
    Notification.where(
      notifiable_type: "Message",
      notifiable_id: @conversation.messages.pluck(:id),
      recipient: current_user,
    ).where.not(read_at: nil).destroy_all

    #! Broadcast again to update unread count once messages are marked as read
    ActionCable.server.broadcast(
      "notifications_#{current_user.id}",
      { conversation_id: @conversation.id, unread_count: 0 }
    )

    head :ok
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
