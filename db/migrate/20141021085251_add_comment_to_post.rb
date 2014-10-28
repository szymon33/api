class AddCommentToPost < ActiveRecord::Migration
  def change
  	# add_reference :comments, :post, index: true
  	add_column :comments, :post_id, :integer
  	add_index :comments, :post_id  	
  end
end
