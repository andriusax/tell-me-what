class ChatsController < ApplicationController
  before_action :find_chat, only: [ :show, :edit, :update ]
  def show
    @messages = @chat.messages
    @message = Message.new
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(chat_params)
    @chat.user = current_user
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @chat.update(chat_params)

    redirect_to chat_path(@chat)
  end


  private

  def find_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:question)
  end
end
