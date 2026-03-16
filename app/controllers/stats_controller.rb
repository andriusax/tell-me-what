class StatsController < ApplicationController
  def index
    @chats_count = current_user.chats.count
    @messages_sent_count = current_user.messages.where(role: "user").count
    @ai_responses_count = current_user.messages.where(role: "assistant").count
  end
end
