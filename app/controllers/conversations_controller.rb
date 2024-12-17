class ConversationsController < ApplicationController
  # before_action :set_conversation, only: %i[show destroy]

  def index
    @conversations = current_user.conversations
      .includes(:sender, recipient: { logo_attachment: :blob })
      .order(updated_at: :desc)
  end

  def create
    @recipient = User.find(params[:recipient_id])
    @conversation = Conversation.between(current_user.id, @recipient.id).first_or_create!(
      sender_id: current_user.id,
      recipient_id: @recipient.id,
    )
    redirect_to conversation_path(@conversation)
  end

  #!without first_or_create we need to do this below
  # def create
  #   @conversation = if Conversation.between(params[:sender_id], params[:recipent_id]).present?
  #                     Conversation.between(params[:sender_id], params[:recipent_id]).first
  #                   else
  #                     Conversation.create!(conversation_params)
  #                   end
  #   redirect_to conversation_messages_path(@conversation)
  # end

  def show
    #find specific conversation between 2 users
    @conversation = current_user.conversations.find(params[:id])
    #find all the messages in that conversation & includes(:sender) avoids N+1 query problem
    @messages = @conversation.messages.ordered.includes(:sender)
    #Since user need to able to sent the message so we need to build message instance aswell.
    @message = @conversation.messages.build #more preferred becuase rails approach
    # @message = Message.new
  end

  def destroy
    @conversation = current_user.conversations.find(params[:id])
    if @conversation.destroy
      redirect_to conversations_path, notice: "Conversation was successfully deleted"
    else
      redirect_to conversations_path, alert: "Conversation could not be deleted"
    end
  end

  private

  # def set_conversation
  #   @conversation = Conversation.find(params[:id])
  # end
end
