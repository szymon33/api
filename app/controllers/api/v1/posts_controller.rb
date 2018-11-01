module API::V1
  class PostsController < ApplicationController
    skip_before_filter :authenticate, only: [:index, :show]
    before_filter :verify_authorized, except: [:index, :create]

    def index
      authorize Post
      posts = Post.all
      render json: posts, status: 200
    end

    def create
      authorize Post
      post = Post.new(post_params)
      post.creator = @current_user
      if post.save
        render json: post, status: :created, location: [:api, :v1, post] # created - 201
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: post, status: 200
    end

    def update
      if post.update_attributes(post_params)
        head :no_content
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      post.destroy
      head 204
    end

    def like
      if post.like!
        head :no_content
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    private

    def post
      @post ||= Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :content)
    end

    def verify_authorized
      authorize post
    end
  end
end
