class MessageChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    if params[:conversation_id].present?
      conversation = Conversation.find(params[:conversation_id])
      if conversation.sender_id == current_user.id || conversation.recipient.id == current_user.id
        stream_from "conversation_#{conversation.id}"
      else
        reject
      end
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
