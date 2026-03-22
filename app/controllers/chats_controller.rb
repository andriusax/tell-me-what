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
    first_message = params.dig(:chat, :question)
    @chat = current_user.chats.build(question: Chat::DEFAULT_TITLE)

    if @chat.save
      @chat.messages.create(role: "user", content: first_message)
      @chat.generate_title_from_first_message

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
    # params.require(:chat).permit(:question, messages_attributes: [ :id, :content, :role ])
  end
end
