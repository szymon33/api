require 'spec_helper'

describe Comment do
  it { validate_presence_of :content }
  it { belong_to :user }
  it { belong_to :post }

  describe 'when create' do
    before(:each) { @comment = FactoryGirl.create(:comment) }

    it 'should be valid' do
      @comment.should be_valid
    end

    it 'should have like counter eql 0' do
      @comment.like_counter.should be 0
    end
  end

  it 'should increase like counter' do
    comment = FactoryGirl.create(:comment)
    expect {
      comment.like
    }.to change { comment.like_counter }.by(1)
  end
end
