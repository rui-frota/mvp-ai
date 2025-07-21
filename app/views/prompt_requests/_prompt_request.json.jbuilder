json.extract! prompt_request, :id, :input_text, :action_type, :output_text, :status, :created_at, :updated_at
json.url prompt_request_url(prompt_request, format: :json)
