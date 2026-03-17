class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  SYSTEM_PROMPT = 'You are an expert music gear researcher with deep knowledge of studio production equipment, live performance rigs, and artist-specific setups. Your knowledge draws from artist interviews, gear forums, music publications, and live performance rider documents.
  When a user gives you the name of a musician or artist, return a structured JSON object with their profile and all known gear they use for production and/or performance.
  Follow these rules strictly:
  * Include all gear you can find. Set confidence as a percentage from 0 to 100.
  * If the artist is unknown or you have no gear data for them, return the JSON with an "error" field explaining this — do not fabricate information.
  * Display all the possible gear you can find about an artist.
  * For picture_search_query, provide a short search string a user could use to find an image of that item — do not invent. Place the name in this url "https://reverb.com/api/listings?query=NAME+OF+THE+GEAR+ONLY"
  Always return valid JSON. No explanation, no preamble — only the JSON object.
  Use this exact schema:
  {
    "artist": {
      "name": "string",
      "located": "string",
      "genres": ["string"],
    },
    "device": [
      {
        "name": "string",
        "category": "string (e.g. synthesizer, DAW, guitar, microphone and be speciofic about which ones)",
        "description": "string (1-2 sentences on what it is and why this artist uses it)",
        "approximate_price_euro": "string (e.g. “€3,200 or discontinued - used market ~€800”)",
        "picture_search_query": "string",
        "confidence": "from 0 to 100%"
      }
    ]
  }'

  def index
    @question = params.dig("chat", "ask_prompt")
    # if params["chat"]
    #   @question = params["chat"]["ask_prompt"]
    # else
    #   @question = nil
    # end

    return if @question.blank?

    begin
      chat = RubyLLM.chat(model: "gpt-4.1").with_instructions(SYSTEM_PROMPT)
      payload = JSON.parse(chat.ask(@question).content)

      if payload["artist"] && payload["device"]
        @artist = payload["artist"]
        @gear   = payload["device"]

        @artist_image_url = fetch_image(@artist["name"])
        @gear_img_url = @gear.map { |gear| fetch_gear_image(gear["picture_search_query"]) }
      else
        @error = payload["error"] || "No gear data returned."
      end

    rescue JSON::ParserError => e
        @error = "Invalid response from AI: #{e.message}"
    rescue => e
        @error = "Something went wrong: #{e.message}"
    end
  end

  private

  def fetch_image(query)
    response = Faraday.get("https://en.wikipedia.org/api/rest_v1/page/summary/#{query.tr(' ', '_')}")
    data = JSON.parse(response.body)
    data.dig("thumbnail", "source")
  rescue
    nil
  end

  def fetch_gear_image(query)
    response = Faraday.get(query)
    data = JSON.parse(response.body)
    data["listings"][0]["photos"][0]["_links"]["full"]
    # listings = data["listings"]
    # photos = listings.map { |listing| listing["photos"] }
    # cleaner = photos.map { |photo| photo }
  rescue
    nil
  end
end
