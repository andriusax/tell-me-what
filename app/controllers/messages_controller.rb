class MessagesController < ApplicationController
  before_action :find_message, only: [ :edit, :update ]

  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    @message.chat = Chat.find(params[:chat_id])
    if @message.save
      redirect_to chat_path(@message.chat)
    else
      @chat = @message.chat
      @messages = @chat.messages
      render "chats/show", status: :unprocessable_entity
    end
  end
  def edit
  end

  def update
    @message.update(message_params)

    redirect_to chat_path(@message.chat)
  end

  private

  def find_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, :role)
  end
end
