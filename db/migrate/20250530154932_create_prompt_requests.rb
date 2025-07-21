class CreatePromptRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :prompt_requests do |t|
      t.text :input_text
      t.string :action_type
      t.text :output_text
      t.string :status

      t.timestamps
    end
  end
end
