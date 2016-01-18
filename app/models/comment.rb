class Comment < ActiveRecord::Base
  include Like

  attr_accessible :content, :like_counter

  belongs_to :post
  belongs_to :creator, class_name: 'User', foreign_key: :user_id

  before_create :set_defaults

  validates_presence_of :creator, :content

  private

  def set_defaults
    self.like_counter = 0
  end
end
