class ChatsController < ApplicationController
  before_action :find_chat, only: [ :show, :edit, :update ]
  SYSTEM_PROMPT = helpers.ai_system_prompt
  def show
    @messages = @chat.messages.order(created_at: :asc)

    @message = Message.new
  end

  def new
    @chat = Chat.new
  end

  def create
    @message = params.dig(:chat, :question)
    @chat = current_user.chats.build(question: Chat::DEFAULT_TITLE)

    if @chat.save
      @chat.messages.create(role: "user", content: @message)
      @chat.generate_title_from_first_message
      begin
        @ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1")
        @ruby_llm_chat.with_instructions(instructions)

        build_chat_history

        response = @ruby_llm_chat.ask(@message)

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

  def chat_context
    "Here is the context of the chat: #{@chat.question}"
  end

  def instructions
    [ SYSTEM_PROMPT, chat_context ].compact.join("\n\n")
  end

  def build_chat_history
    @chat.messages do |message|
      @ruby_llm_chat.add_message(message)
    end
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
end
