class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.integer :like_counter
      t.integer :user_id

      t.timestamps
    end
    add_index :posts, :user_id
  end
end
