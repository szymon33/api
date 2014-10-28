require 'spec_helper'

describe "Comments", type: 'feature' do
  before(:each) { @user = FactoryGirl.create(:user) }
  let(:headers) { { 'ACCEPT' => Mime::JSON, 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password) } }

  describe "POST creates comment" do
    before(:each) do
      @post = FactoryGirl.create(:post) 
      @comment = FactoryGirl.build(:comment)
      @comment.post_id = @post.id
    end

    describe "with valid params" do
      it "creates new comment" do
        @post.id.should_not be_nil
        post "/posts/#{@post.id}/comments", 
          @comment.to_json, 
          headers
        response.status.should == 201
        response.content_type == Mime::JSON 

        response.location.should == post_url(@post)
      end
    end

    it "has user" do 
      post "/posts/#{@post.id}/comments", @comment.to_json, headers  
      response.status.should == 201
      Comment.last.user.username.should eq("pokemon")
    end
      

    describe "with invalid params" do
      it "does not create comment with no content" do
        @comment.content = nil
        post "/posts/#{@post.id}/comments", @comment.to_json, headers  

        response.status.should == 422 # unprocessable_entity
        response.content_type.should == Mime::JSON   
      end
    end
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested comment" do
        @comment = FactoryGirl.create(:comment)
        put "/posts/#{@comment.post_id}/comments/#{@comment.id}",
          { comment: { content: 'edited content' } }.to_json,
          headers

        response.status.should eq(204) # no_content
        @comment.reload.content.should == "edited content"   
      end
    end

    describe "with invalid params" do
      it "unsuccessfull update with no content" do
        @comment = FactoryGirl.create(:comment)
        put "/posts/#{@comment.post_id}/comments/#{@comment.id}", 
          { comment: { content: nil } }.to_json,
          headers

        response.status.should eq(422) 
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested comment" do
      @comment = FactoryGirl.create(:comment)  
 
      delete "/posts/#{@comment.post_id}/comments/#{@comment.id}", {}, headers
      response.status.should eq(204) #no content
    end
  end

 
  describe "LIKE action" do

    before(:each) { @comment = FactoryGirl.create(:comment) }

    it "be JSON request and response" do
      put "/posts/#{@comment.post_id}/comments/#{@comment.id}/like", nil, headers
      response.status.should eq(204) # no_content        
    end

    it "should increase like counter" do
      expect { 
        put "/posts/#{@comment.post_id}/comments/#{@comment.id}/like", nil, headers 
      }.to change{ @comment.reload.like_counter }.by(1)      
    end
  end  
end