class AddUserToComment < ActiveRecord::Migration
  def change
  	# add_reference :comments, :user, index: true
  	add_column :comments, :user_id, :integer
  	add_index :comments, :user_id
  end
end
