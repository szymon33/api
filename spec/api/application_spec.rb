require 'spec_helper'

describe 'Application' do
  it 'root path returns ok message' do
    api_get '/'
    message = json(response.body)
    message.should eq(message: 'OK')
  end

  it 'has missing credentials action' do
    api_get '/posts', format: :json
    response.status.should eq(401)
  end
end
