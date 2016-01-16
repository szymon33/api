require 'spec_helper'

describe User do
  it { validate_presence_of :username }
  it { validate_presence_of :password }
  it { have_many :comments }
  it { have_many :posts }

  it 'is valid' do
    @user = FactoryGirl.create(:user)
    expect(@user).to be_valid
  end
end
