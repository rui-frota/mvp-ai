class CreateProcessedFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :processed_files do |t|

      t.timestamps
    end
  end
end
