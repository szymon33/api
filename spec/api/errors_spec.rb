require 'spec_helper'

describe 'Errors handling', type: 'feature' do
  describe 'GET 404 (active record)' do
    before(:each) { api_get '/posts/foobar' }

    it 'has 404 code' do
      expect(response.status).to eql 404
    end

    it 'is JSON respnose content type' do
      expect(response.content_type).to eql Mime::JSON
    end

    it 'has error Not Found body' do
      message = json(response.body)
      expect(message).to eq(error: 'Not Found')
    end
  end

  describe 'GET 404 (routing error)' do
    before(:each) { api_get '/foobar' }

    it 'has 404 code' do
      expect(response.status).to eql 404
    end

    it 'is JSON respnose content type' do
      expect(response.content_type).to eql Mime::JSON
    end

    it 'has error Not Found body' do
      message = json(response.body)
      expect(message).to eq(error: 'Not Found')
    end
  end
end
