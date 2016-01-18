require 'spec_helper'

describe 'Posts' do
  let(:headers) do
    {
      'ACCEPT' => Mime::JSON,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password)
    }
  end

  let(:basic_post) { FactoryGirl.create(:post, creator: @user) }

  before(:each) { @user = FactoryGirl.create(:user) }

  it 'GET index returns posts in JSON' do
    api_get '/posts', { format: :json }, headers
    expect(response.status).to eq(200)
    expect(response.content_type).to eql Mime::JSON
  end

  describe 'POST creates my post' do
    describe 'with valid params' do
      it 'creates my new post' do
        api_post '/posts',
                 FactoryGirl.attributes_for(:post).to_json,
                 headers
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON

        expect(response.location).to eql "http://api.example.com/posts/#{Post.last.id}"
      end
    end

    it 'has creator' do
      @user = FactoryGirl.create(:user, username: 'Clu')
      post = FactoryGirl.attributes_for(:post)
      api_post '/posts', post.to_json, headers
      expect(response.status).to eql 201
      expect(Post.last.creator).to_not be nil
      expect(Post.last.creator).to eql @user
    end

    describe 'with invalid params' do
      it 'does not create post with no content' do
        api_post '/posts', { post: { content: nil } }.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      it 'is not allowed for guest' do
        @user = FactoryGirl.create(:guest)
        api_post '/posts',
                 FactoryGirl.attributes_for(:post).to_json,
                 headers
        expect(response.status).to eql 403 # forbidden
      end
    end
  end

  describe 'PUT update' do
    let(:put_action) do
      api_put "/posts/#{basic_post.id}",
              { post: { content: 'edited content' } }.to_json,
              headers
    end

    describe 'with valid params' do
      it 'updates my requested post' do
        put_action
        expect(response.status).to eql(204) # no_content
        expect(basic_post.reload.content).to eql 'edited content'
      end
    end

    describe 'with invalid params' do
      it 'unsuccessfull update with no content' do
        api_put "/posts/#{basic_post.id}",
                { post: { content: nil } }.to_json,
                headers
        expect(response.status).to eql(422)
      end
    end

    describe 'with permissions' do
      it 'is not allowed for guest' do
        guest = FactoryGirl.create(:guest)
        post = FactoryGirl.create(:post, creator: guest)
        api_put "/posts/#{post.id}",
                { post: { content: 'edited content' } }.to_json,
                headers
        expect(response.status).to eql(403) # forbidden
      end

      it 'is not allowed for other people posts' do
        stranger = FactoryGirl.create(:user)
        basic_post.update_attribute(:creator, stranger)
        expect(@user).to_not eq stranger
        put_action
        expect(response.status).to eql(403) # forbidden
      end

      it 'admin can change it anyway' do
        user1 = FactoryGirl.create(:user)
        basic_post.update_attribute(:creator, user1)
        @user = FactoryGirl.create(:admin)
        put_action
        expect(response.status).to eql(204) # no_content
      end
    end
  end

  describe 'DELETE destroy' do
    let(:destroy_action) { api_delete "/posts/#{basic_post.id}", {}, headers }

    it 'destroys my requested post' do
      destroy_action
      expect(response.status).to eql(204) # no content
    end

    describe 'with permissions' do
      it 'is not allowed for guest' do
        guest = FactoryGirl.create(:guest)
        post = FactoryGirl.create(:post, creator: guest)
        api_delete "/posts/#{post.id}",
                   { post: { content: 'edited content' } }.to_json,
                   headers
        expect(response.status).to eql(403) # forbidden
      end

      it 'is not allowed for other people posts' do
        basic_post
        @user = FactoryGirl.create(:user) # new current user
        expect(basic_post.creator).to_not eql(@user)
        destroy_action
        expect(response.status).to eql(403) # forbidden
      end

      it 'admin can destroy it anyway' do
        basic_post
        @user = FactoryGirl.create(:admin)
        expect(basic_post.creator).to_not eql(@user)
        destroy_action
        expect(response.status).to eql(204) # no_content
      end
    end
  end

  describe 'LIKE action' do
    let(:like) { api_put "/posts/#{basic_post.id}/like", nil, headers }

    describe 'when valid' do
      it 'has response status with no content' do
        like
        expect(response.status).to eql(204) # no_content
      end

      it 'increases my like counter' do
        expect {
          like
        }.to change{
          basic_post.reload.like_counter
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

    describe 'with permissions' do
      it 'is not allowed for guest' do
        @user = FactoryGirl.create(:guest)
        like
        expect(response.status).to eql 403 # forbidden
      end
    end
  end
end
