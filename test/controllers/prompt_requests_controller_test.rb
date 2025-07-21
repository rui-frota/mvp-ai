require "test_helper"

class PromptRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @prompt_request = prompt_requests(:one)
  end

  test "should get index" do
    get prompt_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_prompt_request_url
    assert_response :success
  end

  test "should create prompt_request" do
    assert_difference("PromptRequest.count") do
      post prompt_requests_url, params: { prompt_request: { action_type: @prompt_request.action_type, input_text: @prompt_request.input_text, output_text: @prompt_request.output_text, status: @prompt_request.status } }
    end

    assert_redirected_to prompt_request_url(PromptRequest.last)
  end

  test "should show prompt_request" do
    get prompt_request_url(@prompt_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_prompt_request_url(@prompt_request)
    assert_response :success
  end

  test "should update prompt_request" do
    patch prompt_request_url(@prompt_request), params: { prompt_request: { action_type: @prompt_request.action_type, input_text: @prompt_request.input_text, output_text: @prompt_request.output_text, status: @prompt_request.status } }
    assert_redirected_to prompt_request_url(@prompt_request)
  end

  test "should destroy prompt_request" do
    assert_difference("PromptRequest.count", -1) do
      delete prompt_request_url(@prompt_request)
    end

    assert_redirected_to prompt_requests_url
  end
end
