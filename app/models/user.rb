require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  ROLES = %w(user admin).freeze

  has_many :comments
  has_many :posts

  validate :username, presence: true, uniqueness: true
  validates_presence_of :password, on: :create
  validates_inclusion_of :role, in: ROLES

  ROLES.each do |r|
    define_method("#{r}?") { role == r }
  end

  def self.authenticate(username, pass)
    if user = User.find_by_username(username)
      user.password == pass
    end
  end

  def password
    @password ||= BCrypt::Password.new(password_hash)
  end

  def password=(new_password)
    BCrypt::Engine.cost = 6 # enough for HTTP Basic Auth
    @password = BCrypt::Password.create(new_password)
    self.password_hash = @password
  end
end
