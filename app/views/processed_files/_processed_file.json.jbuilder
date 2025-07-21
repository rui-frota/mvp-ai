json.extract! processed_file, :id, :document, :created_at, :updated_at
json.url processed_file_url(processed_file, format: :json)
json.document url_for(processed_file.document)
