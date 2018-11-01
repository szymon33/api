require 'spec_helper'

describe 'Comments' do
  let(:headers) do
    {
      'ACCEPT' => Mime::JSON,
      'CONTENT_TYPE' => 'application/json',
      'HTTP_AUTHORIZATION' => encode_credentials(@user.username, 'test')
    }
  end

  let(:basic_comment) { FactoryGirl.create(:comment, creator: @user) }

  before(:each) { @user = User.find_by_role('user') || FactoryGirl.create(:user) }

  describe 'GET index' do
    it 'is success' do
      api_get "/posts/#{basic_comment.post.id}/comments", { format: :json }, headers
      expect(response.status).to eq(200) # success
      expect(response.content_type).to eql Mime::JSON
    end

    describe 'without authentication' do
      it 'is allowed' do
        api_get "/posts/#{basic_comment.post.id}/comments", format: :json
        expect(response.status).to eq(200) # success
        expect(response.content_type).to eql Mime::JSON
      end

      it 'has right amount of records' do
        Comment.delete_all
        post = FactoryGirl.create(:post, creator: @user)
        FactoryGirl.create_list(:comment, 10, creator: @user, post: post)
        api_get "/posts/#{post.id}/comments", format: :json
        expect(post.comments.count).to eq 10
        expect(json[:comments].length).to eq 10
      end
    end
  end

  describe 'POST create' do
    let(:create_action) do
      api_post "/posts/#{@post.id}/comments",
               { comment: FactoryGirl.attributes_for(:comment) }.to_json,
               headers
    end

    before(:each) { @post = FactoryGirl.create(:post) }

    describe 'with valid params' do
      it 'returns created code' do
        create_action
        expect(response.status).to eql 201
        expect(response.content_type).to eql Mime::JSON
        expect(response.location).to eql "http://api.example.com/v1/posts/#{@post.id}"
      end

      it "increases count of post's comments" do
        expect do
          api_post "/posts/#{@post.id}/comments",
                   { comment: FactoryGirl.attributes_for(:comment) }.to_json,
                   headers
        end.to change { @post.reload.comments.count }.by(1)
      end

      it 'has creator' do
        @user = FactoryGirl.create(:user) # other user
        create_action
        expect(response.status).to eql 201
        expect(Comment.last.creator).to_not be nil
        expect(Comment.last.creator).to eql @user
      end

      it 'returns comment' do
        create_action
        expect(json[:comment][:content]).to eq Comment.last.content
      end
    end

    describe 'with invalid params' do
      it 'returns unprocessable entity code' do
        api_post "/posts/#{@post.id}/comments",
                 { comment: { 'content' => nil } }.to_json,
                 headers
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_post "/posts/#{basic_comment.post.id}/comments", format: :json
        expect(response.status).to eql 401 # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end

  describe 'GET show' do
    before do
      api_get "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
              headers
    end

    it 'is success' do
      expect(response.status).to eql 200 # success
      expect(response.content_type).to eql Mime::JSON
    end

    describe 'without authentication' do
      it 'is allowed' do
        expect(response.status).to eql 200 # success
        expect(response.content_type).to eql Mime::JSON
      end
    end

    context 'JSON response' do
      subject { json[:comment] }

      it { is_expected.to include({ id: a_kind_of(Integer) }) }
      it { is_expected.to include({ content: 'Foo Bar' }) }
      it { is_expected.to include({ like_counter: a_kind_of(Integer)}) }
      it { is_expected.to include(:created_at) }
      it { is_expected.to include(:updated_at) }

      it 'is playground' do
        expect(subject[:content].class).to eq String
      end
    end
  end

  describe 'PUT update' do
    let(:put_action) do
      api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
              { comment: { content: 'edited content' } }.to_json,
              headers
    end

    describe 'with valid params' do
      it 'updates requested comment' do
        expect { put_action }.to change { basic_comment.reload.content }
      end

      it 'returns no content code' do
        put_action
        expect(response.status).to eql(204) # no_content
      end
    end

    describe 'with invalid params' do
      it 'returns unprocessable entity' do
        api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                { comment: { content: nil } }.to_json,
                headers
        expect(response.status).to eql(422)
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_put "/posts/#{basic_comment.post.id}", format: :json
        expect(response.status).to eql(401) # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      let!(:stranger) { FactoryGirl.create(:user) }

      describe 'user' do
        it 'can not change other people comments' do
          basic_comment.update_attribute(:creator, stranger)
          expect(@user).to_not eq stranger
          put_action
          expect(response.status).to eql(403) # forbidden
          expect(response.content_type).to eql Mime::JSON
        end

        it 'can not change creator attribute' do
          expect(basic_comment.creator).to eql(@user)
          expect do
            api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                    { comment: { user_id: stranger.id } }.to_json,
                    headers
          end.to_not change { basic_comment.reload.user_id }
        end
      end

      describe 'admin' do
        it 'changes other people creator attribute' do
          @user = FactoryGirl.create(:admin)
          expect do
            api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                    { comment: { user_id: stranger.id } }.to_json,
                    headers
          end.to change { basic_comment.reload.user_id }
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:destroy_action) do
      api_delete "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                 {}, headers
    end

    it 'returns no content code' do
      destroy_action
      expect(response.status).to eql(204) # no content
    end

    it "decrease post's comments count" do
      basic_comment
      expect { destroy_action }.to change { basic_comment.post.comments.count }.by(-1)
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_delete "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}",
                   format: :json
        expect(response.status).to eql(401) # Unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'with permissions' do
      describe 'user' do
        it 'is not allowed for other people comments' do
          basic_comment
          @user = FactoryGirl.create(:user) # new current user
          expect(basic_comment.creator).to_not eql(@user)
          destroy_action
          expect(response.status).to eql(403) # forbidden
          expect(response.content_type).to eql Mime::JSON
        end
      end

      describe 'admin' do
        it 'deletes other people comments' do
          basic_comment
          @user = FactoryGirl.create(:admin)
          expect(basic_comment.creator).to_not eql(@user)
          expect { destroy_action }.to change { Comment.count }.by(-1)
        end
      end
    end
  end

  describe 'LIKE action' do
    let(:like) do
      api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}/like",
              nil,
              headers
    end

    describe 'when valid' do
      it 'returns no content code' do
        like
        expect(response.status).to eql(204) # no_content
      end

      it 'increases like counter' do
        expect { like }.to change { basic_comment.reload.like_counter }.by(1)
      end
    end

    describe 'when invalid' do
      before(:each) { allow_any_instance_of(Comment).to receive(:save).and_return(false) }

      it 'returns unprocessable entity code' do
        like
        expect(response.status).to eql 422 # unprocessable_entity
        expect(response.content_type).to eql Mime::JSON
      end
    end

    describe 'without authentication' do
      it 'returns unauthorized code' do
        api_put "/posts/#{basic_comment.post_id}/comments/#{basic_comment.id}/like",
                format: :json
        expect(response.status).to eql 401 # unauthorized
        expect(response.content_type).to eql Mime::JSON
      end
    end
  end
end
