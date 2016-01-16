require 'spec_helper'

describe 'Status page', type: 'feature' do
  it 'returns JSON message OK' do
    api_get '/status'
    expect(response.status).to eq 200
    message = json(response.body)
    expect(message).to eq(message: 'OK')
  end
end
