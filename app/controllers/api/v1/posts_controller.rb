module API::V1
  class PostsController < ApplicationController
    skip_before_filter :authenticate, only: [:index, :show]
    before_filter :set_post, except: [:create, :index]
    before_filter :user_not_allowed, only: [:update, :destroy]

    def index
      posts = Post.all
      render json: posts, status: 200
    end

    def create
      post = Post.new(post_params)
      post.creator = @current_user
      if post.save
        render json: post, status: :created, location: [:api, :v1, post] # created - 201
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: @post, status: 200
    end

    def update
      if @post.update_attributes(post_params)
        head :no_content
      else
        render json: @post.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      head 204
    end

    def like
      if @post.like!
        head :no_content
      else
        render json: @post.errors, status: 422 # unprocessable_entity
      end
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def user_not_allowed
      return if @current_user.admin?
      return if @current_user.user? && @post.creator == @current_user

      render_forbidden
    end

    def post_params
      if @current_user && @current_user.admin?
        params.require(:post).permit!
      else
        params.require(:post).permit(:title, :content)
      end
    end
  end
end
