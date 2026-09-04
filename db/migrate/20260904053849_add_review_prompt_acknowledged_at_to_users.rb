class AddReviewPromptAcknowledgedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :review_prompt_acknowledged_at, :datetime
  end
end
