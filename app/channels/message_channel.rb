class MessageChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    if params[:conversation_id].present?
      conversation = Conversation.find(params[:conversation_id]) #check if the params[:conversation_id] is present in database aswell through Conversation model.
      if conversation.sender_id == current_user.id || conversation.recipient.id == current_user.id
        #if current user is either sender or receiver.
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
