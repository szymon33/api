require 'spec_helper'

describe "Status page" do

  it "returns JSON message OK" do
    get '/status'
    response.status.should eq 200
    message = json(response.body)
    message.should eq({ message: 'OK'})
  end

end
