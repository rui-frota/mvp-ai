class RenameColumnInProcessedFiles < ActiveRecord::Migration[7.1]
  def change
    rename_column :processed_files, :summary_type, :action_type
  end
end
