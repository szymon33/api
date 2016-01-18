class Comment < ActiveRecord::Base

  include Like

  attr_accessible :content, :like_counter

  belongs_to :creator, class_name: "User", foreign_key: :user_id
  belongs_to :post

  before_create :set_defaults

  validates_presence_of :content

  private

  def set_defaults
    self.like_counter = 0
  end
end
