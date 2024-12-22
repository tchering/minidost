class MessagesController < ApplicationController
  before_action :set_conversation, only: [:create]

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user
    respond_to do |format|
      if @message.save
        ActionCable.server.broadcast(
          "conversation_#{@conversation.id}",
          @message.as_json(include: :sender)
        )
        format.html { redirect_to chat_conversation_path(@conversation) }
      else
        format.html { redirect_to chat_conversation_path(@conversation), status: :unprocessable_entity, alert: "Message failed to sent" }
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
