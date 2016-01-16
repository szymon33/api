require 'spec_helper'

describe 'Status page', type: 'feature' do
  it 'returns JSON message OK' do
    api_get '/status'
    response.status.should eq 200
    message = json(response.body)
    message.should eq(message: 'OK')
  end
end
