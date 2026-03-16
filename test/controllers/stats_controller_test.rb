require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should redirect unauthenticated user to sign in" do
    get stats_url
    assert_redirected_to new_user_session_path
  end

  test "should show stats page for authenticated user" do
    user = User.create!(email: "test@example.com", password: "password123")
    sign_in user
    get stats_url
    assert_response :success
    assert_not_nil assigns(:chats_count)
    assert_not_nil assigns(:messages_sent_count)
    assert_not_nil assigns(:ai_responses_count)
  end
end
