require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  ROLES = %w(user admin).freeze

  attr_accessible :username, :role

  has_many :comments
  has_many :posts

  validate :username, prsence: true, uniqueness: true
  validates_presence_of :password
  validates_inclusion_of :role, in: ROLES

  ROLES.each do |r|
    define_method("#{r}?") { role == r }
  end

  def self.authenticate(username, password)
    if user = User.find_by_username(username)
      password == user.password
    end
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
