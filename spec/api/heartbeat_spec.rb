require 'spec_helper'

describe 'Heartbeat', type: 'feature' do
  describe 'status GET' do
    before(:each) { api_get '/' }

    it 'is success' do
      expect(response.status).to eql 200
    end

    it 'is JSON respnose content type' do
      expect(response.content_type).to eql Mime::JSON
    end

    it 'has OK body' do
      expect(json[:message]).to eq 'OK'
    end
  end
end
