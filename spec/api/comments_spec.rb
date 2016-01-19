require 'spec_helper'

describe 'Comments' do
  let(:headers) do
    {
      'ACCEPT' => Mime::JSON,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password)
    }
  end

  let(:basic_comment) { FactoryGirl.create(:comment, creator: @user) }

  before(:each) { @user = FactoryGirl.create(:user) }

  describe 'POST creates my comment' do
    let(:create_action) do
        api_post "/posts/#{@post.id}/comments",
                 { comment: FactoryGirl.attributes_for(:comment, post_id: @post.id) }.to_json,
                 headers
    end

    before(:each) { @post = FactoryGirl.create(:post) }

    describe 'with valid params' do
      it 'creates my new comment' do
        create_action
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON
        expect(response.location).to eql "http://api.example.com/posts/#{@post.id}"
      end

      it "increases count of post's comments" do
        expect {
          create_action
        }.to change {
          @post.reload.comments.count
        }.by(1)
      end

      it 'has creator' do
        @user = FactoryGirl.create(:user) # other user
        create_action
        expect(response.status).to eql 201
        expect(Comment.last.creator).to_not be nil
        expect(Comment.last.creator).to eql @user
      end
    end

    describe 'with invalid params' do
      it 'does not create comment with no content' do
        api_post "/posts/#{@post.id}/comments",
                 { comment: { 'content' => nil } }.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      it 'is not allowed for guest' do
        @user = FactoryGirl.create(:guest)
        create_action
        expect(response.status).to eql 403 # forbidden
      end
    end
  end

  describe 'GET show' do
    it 'gets single comment' do
      api_get "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
              basic_comment.to_json,
              headers
      expect(response.status).to eql 200
      expect(response.content_type).to eql Mime::JSON
    end
  end

  describe 'PUT update' do
    let(:put_action) do
      api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
              { comment: { content: 'edited content' } }.to_json,
              headers
    end

    describe 'with valid params' do
      it 'updates my requested comment' do
        put_action
        expect(response.status).to eql(204) # no_content
        expect(basic_comment.reload.content).to eql 'edited content'
      end
    end

    describe 'with invalid params' do
      it 'unsuccessfull update with no content' do
        api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                { comment: { content: nil } }.to_json,
                headers
        expect(response.status).to eql(422)
      end
    end

    describe 'with permissions' do
      it 'is not allowed for guest' do
        guest = FactoryGirl.create(:guest)
        comment = FactoryGirl.create(:comment, creator: guest)
        api_put "/posts/#{comment.post_id}/comments/#{comment.id}",
                { comment: { content: 'edited content' } }.to_json,
                headers
        expect(response.status).to eql(403) # forbidden
      end

      it 'is not allowed for other people posts' do
        stranger = FactoryGirl.create(:user)
        basic_comment.update_attribute(:creator, stranger)
        expect(@user).to_not eq stranger
        put_action
        expect(response.status).to eql(403) # forbidden
      end

      it 'admin can change it anyway' do
        user1 = FactoryGirl.create(:user)
        basic_comment.update_attribute(:creator, user1)
        @user = FactoryGirl.create(:admin)
        put_action
        expect(response.status).to eql(204) # no_content
      end
    end
  end

  describe 'DELETE destroy' do
    let(:destroy_action) do
      api_delete "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                 {}, headers
    end
    it 'destroys my requested comment' do
      destroy_action
      expect(response.status).to eql(204) # no content
    end
    describe 'with permissions' do
      it 'is not allowed for guest' do
        guest = FactoryGirl.create(:guest)
        comment = FactoryGirl.create(:comment, creator: guest)
        api_delete "/posts/#{comment.post_id}/comments/#{comment.id}", {}, headers
        expect(response.status).to eql(403) # forbidden
      end

      it 'is not allowed for other people comments' do
        basic_comment
        @user = FactoryGirl.create(:user) # new current user
        expect(basic_comment.creator).to_not eql(@user)
        destroy_action
        expect(response.status).to eql(403) # forbidden
      end

      it 'admin can destroy it anyway' do
        basic_comment
        @user = FactoryGirl.create(:admin)
        expect(basic_comment.creator).to_not eql(@user)
        destroy_action
        expect(response.status).to eql(204) # no_content
      end
    end
  end

  describe 'LIKE action' do
    let(:like) { api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}/like", nil, headers }

    describe 'when valid' do
      it 'has resonse status with no content' do
        like
        expect(response.status).to eql(204) # no_content
      end

      it 'increases like counter' do
        expect {
          like
        }.to change {
          basic_comment.reload.like_counter
        }.by(1)
      end
    end

    describe 'when invalid' do
      before(:each) { allow_any_instance_of(Comment).to receive(:save).and_return(false) }
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
