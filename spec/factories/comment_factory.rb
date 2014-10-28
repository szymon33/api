FactoryGirl.define do 
  factory(:comment) do
    content "Allahu Akbar"
    association :post
  end  
end