require 'spec_helper'

describe Post do 
  it { validate_presence_of :content }
  it { validate_presence_of :title }
  it { belong_to :user }
  it { have_many :comments }

  describe "when create" do
  	before(:each) { @post = FactoryGirl.create(:post) }

  	it "should be valid" do  
  	  @post.should be_valid
  	end

  	it "should have like counter eql 0" do
  	  @post.like_counter.should be 0
  	end
  end

	
  it "should increase like counter" do
  	post = FactoryGirl.create(:post)
    expect {
      post.like	
    }.to change { post.like_counter }.by(1) 
  end
end