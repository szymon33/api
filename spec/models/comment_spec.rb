require 'spec_helper'

describe Comment do
  it { validate_presence_of :content }
  it { validate_presence_of :creator }
  it { validate_presence_of :post }
  it { belong_to(:user).with_foreign_key('user_id') }
  it { belong_to :post }

  let(:comment) { FactoryGirl.create(:comment) }

  describe 'when create' do
    it 'is valid' do
      expect(comment).to be_valid
    end

    it 'has like counter eql 0' do
      expect(comment.like_counter).to be_zero
    end
  end

  it 'can increase like counter' do
    expect { comment.like! }.to change { comment.like_counter }.by(1)
  end
end
