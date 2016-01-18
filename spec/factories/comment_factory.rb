FactoryGirl.define do
  factory(:comment) do
    content 'Foo Bar'
    association :post
    association :creator, factory: :user
  end
end
