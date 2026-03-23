class Message < ApplicationRecord
  belongs_to :chat

  MAX_USER_MESSAGES = 10

  after_create :enforce_message_limit, if: -> { role == "user"}

  private

  def enforce_message_limit
    user_messages = chat.messages.where(role: "user").order(:created_at)
    if user_messages.count > MAX_USER_MESSAGES
      user_messages.first.destroy
    end
  end
end
