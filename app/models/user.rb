class User < ActiveRecord::Base
  ROLES = %w(guest user admin).freeze

  attr_accessible :password, :username, :role

  has_many :comments
  has_many :posts

  validate :username, prsence: true, uniqueness: true
  validates_presence_of :password
  validates_inclusion_of :role, in: ROLES

  ROLES.each do |r|
    define_method("#{r}?") { role == r }
  end

  def self.authenticate(username, password)
    if u = User.find_by_username(username)
      u.password == password
    end
  end
end
