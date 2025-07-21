require "test_helper"

class ProcessedFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @processed_file = processed_files(:one)
  end

  test "should get index" do
    get processed_files_url
    assert_response :success
  end

  test "should get new" do
    get new_processed_file_url
    assert_response :success
  end

  test "should create processed_file" do
    assert_difference("ProcessedFile.count") do
      post processed_files_url, params: { processed_file: {  } }
    end

    assert_redirected_to processed_file_url(ProcessedFile.last)
  end

  test "should show processed_file" do
    get processed_file_url(@processed_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_processed_file_url(@processed_file)
    assert_response :success
  end

  test "should update processed_file" do
    patch processed_file_url(@processed_file), params: { processed_file: {  } }
    assert_redirected_to processed_file_url(@processed_file)
  end

  test "should destroy processed_file" do
    assert_difference("ProcessedFile.count", -1) do
      delete processed_file_url(@processed_file)
    end

    assert_redirected_to processed_files_url
  end
end
