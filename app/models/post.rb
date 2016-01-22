class Post < ActiveRecord::Base
  include Like

  has_many :comments, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: :user_id
  validates_presence_of :content, :title, :creator
end
