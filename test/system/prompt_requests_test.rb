require "application_system_test_case"

class PromptRequestsTest < ApplicationSystemTestCase
  setup do
    @prompt_request = prompt_requests(:one)
  end

  test "visiting the index" do
    visit prompt_requests_url
    assert_selector "h1", text: "Prompt requests"
  end

  test "should create prompt request" do
    visit prompt_requests_url
    click_on "New prompt request"

    fill_in "Action type", with: @prompt_request.action_type
    fill_in "Input text", with: @prompt_request.input_text
    fill_in "Output text", with: @prompt_request.output_text
    fill_in "Status", with: @prompt_request.status
    click_on "Create Prompt request"

    assert_text "Prompt request was successfully created"
    click_on "Back"
  end

  test "should update Prompt request" do
    visit prompt_request_url(@prompt_request)
    click_on "Edit this prompt request", match: :first

    fill_in "Action type", with: @prompt_request.action_type
    fill_in "Input text", with: @prompt_request.input_text
    fill_in "Output text", with: @prompt_request.output_text
    fill_in "Status", with: @prompt_request.status
    click_on "Update Prompt request"

    assert_text "Prompt request was successfully updated"
    click_on "Back"
  end

  test "should destroy Prompt request" do
    visit prompt_request_url(@prompt_request)
    click_on "Destroy this prompt request", match: :first

    assert_text "Prompt request was successfully destroyed"
  end
end
