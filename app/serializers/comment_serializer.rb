class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content, :like_counter, :created_at, :updated_at, :user_id, :post_id
end
