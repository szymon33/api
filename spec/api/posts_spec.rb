require 'spec_helper'

describe 'Posts' do
  let(:headers) do
    {
      'ACCEPT' => Mime::JSON,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password)
    }
  end

  before(:each) { @user = FactoryGirl.create(:user) }

  it 'GET index returns posts in JSON' do
    api_get '/posts', { format: :json }, headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eql Mime::JSON
  end

  describe 'POST creates post' do
    describe 'with valid params' do
      it 'creates new post' do
        post 'http://api.example.com/posts',
             FactoryGirl.attributes_for(:post).to_json,
             headers
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON

        response.location.should == "http://api.example.com/posts/#{Post.last.id}"
      end
    end

    it 'has user' do
      @post = FactoryGirl.attributes_for(:post)

      api_post '/posts', @post.to_json, headers
      expect(response.status).to eql 201
      Post.last.user.username.should eq('pokemon')
    end

    describe 'with invalid params' do
      it 'does not create post with no content' do
        api_post '/posts', { post: { content: nil } }.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested post' do
        @post = FactoryGirl.create(:post)
        api_put "/posts/#{@post.id}",
                { post: { content: 'edited content' } }.to_json,
                headers
        response.status.should eq(204) # no_content
        @post.reload.content.should == 'edited content'
      end
    end

    describe 'with invalid params' do
      it 'unsuccessfull update with no content' do
        @post = FactoryGirl.create(:post)
        api_put "/posts/#{@post.id}",
                { post: { content: nil } }.to_json,
                headers
        response.status.should eq(422)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested post' do
      @post = FactoryGirl.create(:post)
      api_delete "/posts/#{@post.id}", {}, headers
      response.status.should eq(204) # no content
    end
  end

  describe 'LIKE action' do
    before(:each) { @post = FactoryGirl.create(:post) }
    let(:like) { api_put "/posts/#{@post.id}/like", nil, headers }

    describe 'when valid' do
      it 'has resonse status with no content' do
        like
        response.status.should eq(204) # no_content
      end

      it 'should increase like counter' do
        expect {
          like
        }.to change{
          @post.reload.like_counter
        }.by(1)
      end
    end

    describe 'when invalid' do
      before(:each) { allow_any_instance_of(Post).to receive(:save).and_return(false) }
      it 'has unsuccessful update' do
        like
        expect(response.status).to eql 422 # unprocessable_entity        
      end
    end
  end
end
