class MessagesController < ApplicationController
  before_action :find_message, only: [ :edit, :update ]
  # application helpers
  SYSTEM_PROMPT = helpers.ai_system_prompt

  # gpt-4o
  # gpt-4.1
  # RubyLLM.models.all.map(&:id)

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      begin
        @ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1")
        @ruby_llm_chat.with_instructions(instructions)

        build_chat_history

        response = @ruby_llm_chat.ask(@message.content)

        payload = JSON.parse(response.content)

        if payload["artist"].is_a?(Hash)
          payload["artist"]["image_url"] = fetch_image(payload.dig("artist", "picture_search_query"))
        elsif payload["artist"].is_a?(Array)
          payload["artist"].each do |artist|
            artist["image_url"] = fetch_image(artist["picture_search_query"])
          end
        end

        payload["device"]&.each do |device|
          device["image_url"] = fetch_gear_image(device["picture_search_query"])
        end

        content = JSON.generate(payload)

        @chat.messages.create(
          role: "TMW",
          content: content
        )

        # rescue => e
        #   Rails.logger.error "AI error: #{e.message}"
      end

      respond_to do |format|
        format.turbo_stream # messages#create.turbo_stream.erb
        format.html { redirect_to chat_path(@chat) }
      end
    else
      @message = @chat.messages
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
    if params[:message].present?
      params.require(:message).permit(:content, :role)
    else
      {}
    end
  end

  def chat_context
    "Here is the context of the chat: #{@chat.question}"
  end

  def instructions
    [ SYSTEM_PROMPT, chat_context ].compact.join("\n\n")
  end

  def fetch_image(query)
    response = Faraday.get("https://en.wikipedia.org/api/rest_v1/page/summary/#{query.tr(' ', '_')}")
    data = JSON.parse(response.body)
    data.dig("thumbnail", "source")
  rescue
    nil
  end

  def fetch_gear_image(gear_name)
    response = Faraday.get("https://en.wikipedia.org/api/rest_v1/page/summary/#{gear_name.tr(' ', '_')}")

    data = JSON.parse(response.body)
    data.dig("originalimage", "source")
  rescue
    "https://placehold.co/300x300?text=#{URI.encode_www_form_component(gear_name)}"
  end

  def build_chat_history
    @chat.messages do |message|
      @ruby_llm_chat.add_message(message)
    end
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
