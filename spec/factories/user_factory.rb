FactoryGirl.define do
  factory(:user) do
    username 'pokemon'
    password 'test'
    role 'user'

    factory(:admin) do
      username 'adminuser'
      password '12345'
      role 'admin'
    end

    factory :guest do
      username 'guestuser'
      password 'guest'
    end
  end
end
