class MessagesController < ApplicationController
  before_action :find_message, only: [ :edit, :update ]
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
    params.require(:message).permit(:content)
  end
end
