module API
  class PostsController < ApplicationController
    before_filter :set_post, except: [:index, :create]
    before_filter :user_not_allowed, only: [:update, :destroy]
    before_filter :guest_not_allowed, except: [:index, :show]

    def index
      posts = Post.all
      respond_to do |format|
        format.json { render json: posts, status: 200 }
      end
    end

    def create
      post = Post.new(params[:post])
      post.creator = current_user
      if post.save
        render json: post, status: :created, location: [:api, post] # created - 201
        # render nothing: true, status: 204, location: post # no_content
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: @post, status: 200
    end

    def update
      if @post.update_attributes(params[:post])
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
      if @post.like
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
      unless (current_user.user? && @post.creator == current_user) || current_user.admin?
        head 403 # forbidden
      end
    end
  end
end
