require 'spec_helper'

describe "Posts", type: 'feature' do
  before(:each) { @user = FactoryGirl.create(:user) }
  let(:headers) { { 'ACCEPT' => Mime::JSON, 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => encode_credentials(@user.username, @user.password) } }

  it "GET index returns posts in JSON" do
    get '/posts', headers
    response.status.should eq(200)
    response.content_type.should == Mime::JSON
  end

  describe "POST creates post" do
    describe "with valid params" do
      it "creates new post" do

        post "/posts", 
          FactoryGirl.attributes_for(:post).to_json, 
          headers
        response.status.should == 201
        response.content_type == Mime::JSON 

        post = json(response.body)
        response.location.should == post_url(post[:id])
      end
    end

    it "has user" do 
      @post = FactoryGirl.attributes_for(:post)
     
      post "/posts", @post.to_json, headers  
      response.status.should == 201
      Post.last.user.username.should eq("pokemon")
    end
      

    describe "with invalid params" do
      it "does not create post with no content" do
        post '/posts', {:post => {:content => nil}}.to_json,  
          headers

        response.status.should == 422 # unprocessable_entity
        response.content_type.should == Mime::JSON   
      end
    end
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested post" do
        @post = FactoryGirl.create(:post)
        put "/posts/#{@post.id}",
          { post: { content: 'edited content' } }.to_json,
          headers

        response.status.should eq(204) # no_content
        @post.reload.content.should == "edited content"   
      end
    end

    describe "with invalid params" do
      it "unsuccessfull update with no content" do
        @post = FactoryGirl.create(:post)
        put "/posts/#{@post.id}", 
          { post: { content: nil } }.to_json,
          headers

        response.status.should eq(422) 
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested post" do
      @post = FactoryGirl.create(:post)  
 
      delete "/posts/#{@post.id}", {}, headers
      response.status.should eq(204) #no content
    end
  end

 
  describe "LIKE action" do

    before(:each) { @post = FactoryGirl.create(:post) }

    it "be JSON request and response" do
      put "/posts/#{@post.id}/like", nil, headers
      response.status.should eq(204) # no_content        
    end

    it "should increase like counter" do
      expect { 
        put "/posts/#{@post.id}/like", nil, headers 
      }.to change{ @post.reload.like_counter }.by(1)      
    end
  end  
end