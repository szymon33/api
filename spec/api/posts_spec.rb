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

  describe 'GET index' do
    it 'is success' do
      api_get '/posts', { format: :json }, headers
      expect(response.status).to eq(200) # success
      expect(response.content_type).to eql Mime::JSON
    end

    describe 'without authentication' do
      it 'is allowed' do
        api_get '/posts', format: :json
        expect(response.status).to eq(200) # success
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end

  describe 'POST create' do
    let(:create_action) do
      api_post '/posts',
               FactoryGirl.attributes_for(:post).to_json,
               headers
    end

    describe 'with valid params' do
      it 'returns created code' do
        create_action
        expect(response.status).to eql 201 # created
        expect(response.content_type).to eql Mime::JSON
        expect(response.location).to eql "http://api.example.com/posts/#{Post.last.id}"
      end

      it 'creates new post' do
        expect { create_action }.to change { Post.count }.by(1)
      end

      it 'has creator' do
        @user = FactoryGirl.create(:user) # other user
        create_action
        expect(response.status).to eql 201
        expect(Post.last.creator).to_not be nil
        expect(Post.last.creator).to eql @user
      end
    end

    describe 'with invalid params' do
      it 'returns unprocessable entity code' do
        api_post '/posts',
                 { post: { 'content' => nil } }.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_post '/posts', format: :json
        expect(response.status).to eql 401 # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end

  describe 'GET show' do
    it 'is success' do
      api_get "/posts/#{basic_post.id}", headers
      expect(response.status).to eql 200 # success
      expect(response.content_type).to eql Mime::JSON
    end

    describe 'without authentication' do
      it 'is allowed' do
        api_get "/posts/#{basic_post.id}", basic_post.to_json, format: :json
        expect(response.status).to eql 200 # success
        expect(response.content_type).to eql Mime::JSON
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
      it 'updates requested post' do
        expect { put_action }.to change { basic_post.reload.content }
      end

      it 'returns no content code' do
        put_action
        expect(response.status).to eql(204) # no_content
      end
    end

    describe 'with invalid params' do
      it 'returns unprocessable entity' do
        api_put "/posts/#{basic_post.id}",
                { post: { content: nil } }.to_json,
                headers
        expect(response.status).to eql(422)
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_put "/posts/#{basic_post.id}", format: :json
        expect(response.status).to eql(401) # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      let!(:stranger) { FactoryGirl.create(:user) }

      describe 'user' do
        it 'can not change other people posts' do
          basic_post.update_attribute(:creator, stranger)
          expect(@user).to_not eq stranger
          put_action
          expect(response.status).to eql(403) # forbidden
          expect(response.content_type).to eql Mime::JSON
        end

        it 'can not change creator attribute' do
          expect(basic_post.creator).to eql(@user)
          expect do
            api_put "/posts/#{basic_post.id}",
                    { post: { user_id: stranger.id } }.to_json,
                    headers
          end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
        end
      end

      describe 'admin' do
        it 'changes other people creator attribute' do
          basic_post.update_attribute(:creator, stranger)
          @user = FactoryGirl.create(:admin)
          put_action
          expect(response.status).to eql(204) # no_content
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:destroy_action) { api_delete "/posts/#{basic_post.id}", {}, headers }

    it 'returns no content code' do
      destroy_action
      expect(response.status).to eql(204) # no content
    end

    it 'deletes a post' do
      basic_post
      expect { destroy_action }.to change { Post.count }.by(-1)
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_delete "/posts/#{basic_post.id}", format: :json
        expect(response.status).to eql(401) # Unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      describe 'user' do
        it 'is not allowed for other people posts' do
          basic_post
          @user = FactoryGirl.create(:user) # new current user
          expect(basic_post.creator).to_not eql(@user)
          destroy_action
          expect(response.status).to eql(403) # forbidden
          expect(response.content_type).to eql Mime::JSON
        end
      end

      describe 'admin' do
        it 'deletes other people posts' do
          basic_post
          @user = FactoryGirl.create(:admin)
          expect(basic_post.creator).to_not eql(@user)
          expect { destroy_action }.to change { Post.count }.by(-1)
        end
      end
    end
  end

  describe 'LIKE action' do
    let(:like) { api_put "/posts/#{basic_post.id}/like", nil, headers }

    describe 'when valid' do
      it 'returns no content code' do
        like
        expect(response.status).to eql(204) # no_content
      end

      it 'increases like counter' do
        expect { like }.to change { basic_post.reload.like_counter }.by(1)
      end
    end

    describe 'when invalid' do
      before(:each) { allow_any_instance_of(Post).to receive(:save).and_return(false) }

      it 'returns unprocessable entity code' do
        like
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_put "/posts/#{basic_post.id}/like", format: :json
        expect(response.status).to eql 401 # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end
end
