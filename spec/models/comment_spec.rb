require 'spec_helper'

describe Comment do
  it { validate_presence_of :content }
  it { belong_to :user }
  it { belong_to :post }

  describe 'when create' do
    before(:each) { @comment = FactoryGirl.create(:comment) }

    it 'is valid' do
      expect(@comment).to be_valid
    end

    it 'has like counter eql 0 by defaut' do
      expect(@comment.like_counter).to be_zero
    end
  end

  it 'can increase like counter' do
    comment = FactoryGirl.create(:comment)
    expect {
      comment.like
    }.to change { comment.like_counter }.by(1)
  end
end
