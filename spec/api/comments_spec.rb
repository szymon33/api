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
        @post.id.should_not be_nil
        api_post "/posts/#{@post.id}/comments",
                 @comment.to_json,
                 headers
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON
        expect(response.location).to eql "http://api.example.com/posts/#{@post.id}"
      end
    end

    it 'has user' do
      api_post "/posts/#{@post.id}/comments", @comment.to_json, headers
      expect(response.status).to eql 201
      Comment.last.user.username.should eq('pokemon')
    end

    describe 'with invalid params' do
      it 'does not create comment with no content' do
        @comment.content = nil
        api_post "/posts/#{@post.id}/comments",
                 @comment.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        response.content_type.should == Mime::JSON
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested comment' do
        @comment = FactoryGirl.create(:comment)
        api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}",
                { comment: { content: 'edited content' } }.to_json,
                headers
        response.status.should eq(204) # no_content
        @comment.reload.content.should == 'edited content'
      end
    end

    describe 'with invalid params' do
      it 'unsuccessfull update with no content' do
        @comment = FactoryGirl.create(:comment)
        api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}",
                { comment: { content: nil } }.to_json,
                headers

        response.status.should eq(422)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested comment' do
      @comment = FactoryGirl.create(:comment)

      api_delete "/posts/#{@comment.post_id}/comments/#{@comment.id}", {}, headers
      response.status.should eq(204) # no content
    end
  end

  describe 'LIKE action' do
    before(:each) { @comment = FactoryGirl.create(:comment) }

    it 'be JSON request and response' do
      api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}/like", nil, headers
      response.status.should eq(204) # no_content
    end

    it 'should increase like counter' do
      expect {
        api_put "/posts/#{@comment.post_id}/comments/#{@comment.id}/like", nil, headers
      }.to change{
        @comment.reload.like_counter
      }.by(1)
    end
  end
end
