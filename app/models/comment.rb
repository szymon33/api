class Comment < ActiveRecord::Base
  include Like

  attr_accessible :content

  belongs_to :post
  belongs_to :creator, class_name: 'User', foreign_key: :user_id
  validates_presence_of :creator, :content, :post
end
