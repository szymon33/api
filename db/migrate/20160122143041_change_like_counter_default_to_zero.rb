class ChangeLikeCounterDefaultToZero < ActiveRecord::Migration
  def up
    change_column_default(:posts, :like_counter, 0)
    change_column_default(:comments, :like_counter, 0)
  end

  def down
    change_column_default(:comments, :like_counter, nil)
    change_column_default(:posts, :like_counter, nil)
  end
end
