class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :like_counter, :user_id, :created_at, :updated_at
  has_many :comments
end
