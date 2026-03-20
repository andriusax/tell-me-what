class MessagesController < ApplicationController
  before_action :find_message, only: [ :edit, :update ]
  SYSTEM_PROMPT =
  'You are an expert music gear researcher with deep knowledge of studio
  production equipment, live performance rigs, and artist-specific setups.
  Your knowledge draws from artist interviews, gear forums, music
  publications, and live performance rider documents.

  You are also a chat assistant, so you can answer general questions about
  artists, gear, and music production in a conversational way.

  Always return the answer as a structured JSON object. Your answer can go
  three ways:

  - Use message_type "description" when the user asks a general question
    about an artist, a genre, or a single piece of gear. Put the full
    conversational response in the "message" field. Include 1 device
    maximum only if directly relevant, otherwise leave device empty.

  - Use message_type "cards_focused" when the user asks a focused question
    like "what gear does <artist> use the most" or "what is <artist>
    favourite synth". Include only the most relevant 1-5 devices with
    longer, more detailed descriptions. Put a short intro in "message".

  - Use message_type "cards" only when the user explicitly asks for ALL
    the gear an artist uses, like "list all gear" or "show me everything".
    Include all known devices with short descriptions. Important that for "picture_search_query"
    make a value of "NAME_OF_THE_GEAR_ONLY"

  Follow these rules strictly:
  - Include all gear you can find.
  - Set confidence as a percentage from 0 to 100.
  - If the artist is unknown or you have no gear data for them, return the
    JSON with an "error" field explaining this — do not fabricate information.
  - Display all the possible gear you can find about an artist.
  - The artist block is optional — only include it when the question is
    about a specific artist.


  Use this exact schema:
  {
    "message_type": "description" | "cards_focused" | "cards",
    "message": "string (for description type, put the full response here)",
    "artist": {
      "name": "string",
      "located": "string",
      "genres": ["string"],
      "picture_search_query": "string"
    },
    "device": [
      {
        "name": "string",
        "category": "string (e.g. synthesizer, DAW, guitar, microphone
          and be specific about which ones)",
        "description": "string (1-2 sentences on what it is and why this
          artist uses it)",
        "price": "string (e.g. €3,200 or discontinued - used market ~€800)",
        "picture_search_query": "string",
        "confidence": "0 to 100%"
      }
    ]
  }'
  # gpt-4o
  # gpt-4.1
  # RubyLLM.models.all.map(&:id)

  def create
    @chat = Chat.find(params[:chat_id])
    @message = @chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      begin
        ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1")
        Rails.logger.info "=== Provider: #{ruby_llm_chat.model.provider}"
        ruby_llm_chat.with_instructions(SYSTEM_PROMPT)

        response = ruby_llm_chat.ask(@message.content)

        payload = JSON.parse(response.content)


        payload["artist"]["image_url"] = fetch_image(payload.dig("artist", "picture_search_query")) if payload["artist"].present?

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
    params.require(:message).permit(:content, :role)
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
