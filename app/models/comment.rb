class Comment < ActiveRecord::Base

  include Like

  attr_accessible :content, :like_counter, :user

  belongs_to :creator, class_name: "User", foreign_key: :user_id
  belongs_to :post

  before_create :set_defaults

  validates_presence_of :content

  def like
    self.like_counter += 1
    save
  end

  private

  def set_defaults
    self.like_counter = 0
  end
end
