FactoryGirl.define do
  factory(:comment) do
    content 'Foo Bar'
    association :post
  end
end
