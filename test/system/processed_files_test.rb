require "application_system_test_case"

class ProcessedFilesTest < ApplicationSystemTestCase
  setup do
    @processed_file = processed_files(:one)
  end

  test "visiting the index" do
    visit processed_files_url
    assert_selector "h1", text: "Processed files"
  end

  test "should create processed file" do
    visit processed_files_url
    click_on "New processed file"

    click_on "Create Processed file"

    assert_text "Processed file was successfully created"
    click_on "Back"
  end

  test "should update Processed file" do
    visit processed_file_url(@processed_file)
    click_on "Edit this processed file", match: :first

    click_on "Update Processed file"

    assert_text "Processed file was successfully updated"
    click_on "Back"
  end

  test "should destroy Processed file" do
    visit processed_file_url(@processed_file)
    click_on "Destroy this processed file", match: :first

    assert_text "Processed file was successfully destroyed"
  end
end
