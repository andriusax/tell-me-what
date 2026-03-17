class MessagesController < ApplicationController
  before_action :find_message, only: [ :edit, :update ]

  def new
    @message = Message.new
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @user_message = Message.create(content: message_params[:content], role: "user", chat: @chat)

    save_ai_response(@user_message.content)

    redirect_to chat_path(@chat)
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

  def save_ai_response(user_input)
    # your AI API call should go here
    raw_response = '{ "text": "I found a great photo of Paris for you!", "image_url": "https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=500" }'
    data = JSON.parse(raw_response)

    Message.create(
    chat: @chat,
    content: data["text"],
    image_url: data["image_url"],
    role: "assistant"
    )
  end
end
