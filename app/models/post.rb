class Post < ActiveRecord::Base
  include Like

  attr_accessible :content, :title, :like_counter

  has_many :comments, dependent: :destroy
  belongs_to :creator, class_name: 'User', foreign_key: :user_id
  validates_presence_of :content, :title

  before_create :set_defaults

  private

  def set_defaults
    self.like_counter = 0
  end
end
