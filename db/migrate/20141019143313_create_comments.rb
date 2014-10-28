class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :like_counter

      t.timestamps
    end
  end
end
