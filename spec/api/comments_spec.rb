require 'spec_helper'

describe 'Comments' do
  let(:headers) do
    {
      'ACCEPT' => Mime::JSON,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password)
    }
  end

  before(:each) { @user = FactoryGirl.create(:user) }

  describe 'POST creates comment' do
    before(:each) do
      @post = FactoryGirl.create(:post)
      @comment = FactoryGirl.build(:comment)
      @comment.post_id = @post.id
    end

    describe 'with valid params' do
      it 'creates new comment' do
        expect(@post.id).to_not be nil
        api_post "/posts/#{@post.id}/comments",
                 @comment.to_json,
                 headers
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON
        expect(response.location).to eql "http://api.example.com/posts/#{@post.id}"
      end
    end

    it 'has creator' do
      @user = FactoryGirl.create(:user, username: 'Clu')
      @comment = FactoryGirl.attributes_for(:comment, post: @post)
      api_post "/posts/#{@post.id}/comments",
               @comment.to_json,
               headers
      expect(response.status).to eql 201
      expect(Comment.last.creator).to_not be nil
      expect(Comment.last.creator).to eql @user
    end

    describe 'with invalid params' do
      it 'does not create comment with no content' do
        @comment.content = nil
        api_post "/posts/#{@post.id}/comments",
                 @comment.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end

  describe 'GET show' do
    it 'gets single comment' do
      @comment = FactoryGirl.create(:comment)
      api_get "/posts/#{@comment.post.id}/comments/#{@comment.id}",
              @comment.to_json,
              headers
      expect(response.status).to eql 200
      expect(response.content_type).to eql Mime::JSON
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested comment' do
        @comment = FactoryGirl.create(:comment)
        api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}",
                { comment: { content: 'edited content' } }.to_json,
                headers
        expect(response.status).to eql(204) # no_content
        expect(@comment.reload.content).to eql 'edited content'
      end
    end

    describe 'with invalid params' do
      it 'unsuccessfull update with no content' do
        @comment = FactoryGirl.create(:comment)
        api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}",
                { comment: { content: nil } }.to_json,
                headers

        expect(response.status).to eql(422)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested comment' do
      @comment = FactoryGirl.create(:comment)

      api_delete "/posts/#{@comment.post_id}/comments/#{@comment.id}", {}, headers
      expect(response.status).to eql(204) # no content
    end
  end

  describe 'LIKE action' do
    before(:each) { @comment = FactoryGirl.create(:comment) }
    let(:like) { api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}/like", nil, headers }

    describe 'when valid' do
      it 'has resonse status with no content' do
        like
        expect(response.status).to eql(204) # no_content
      end

      it 'increases like counter' do
        expect {
          like
        }.to change{
          @comment.reload.like_counter
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
  end
end
