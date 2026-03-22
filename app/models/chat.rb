class Chat < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy

  accepts_nested_attributes_for :messages

  DEFAULT_TITLE = "New chat"
  TITLE_PROMPT = <<~PROMPT
    Generate a short, descriptive, 3-to-6 word title that summarizes the user question for a chat conversation
  PROMPT

  def generate_title_from_first_message
    return unless question == DEFAULT_TITLE

    first_user_message = messages.where(role: "user").order(:created_at).first
    return if first_user_message.nil?

    response =
    RubyLLM.chat(model: "gpt-4.1").with_instructions(TITLE_PROMPT).ask(first_user_message.content)
    update(question: response.content)
  end
end
