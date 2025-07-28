class AddFieldsToProcessedFiles < ActiveRecord::Migration[7.1]
  def change
    add_column :processed_files, :summary_type, :string
    add_column :processed_files, :summary, :text
    add_column :processed_files, :status, :string
    add_column :processed_files, :filename, :string
  end
end
