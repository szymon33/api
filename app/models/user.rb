class User < ActiveRecord::Base
  attr_accessible :password, :username

  has_many :comments
  has_many :posts

  validates_presence_of :username, :password

  def self.authenticate(username, password)
    if u = User.find_by_username(username)
      u.password == password
    end
  end
end
