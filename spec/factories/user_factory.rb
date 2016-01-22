FactoryGirl.define do
  factory(:user) do
    sequence :username do |n|
      "pokemon#{n}"
    end
    password 'test'
    role 'user'

    factory(:admin) do
      role 'admin'
    end
  end
end
