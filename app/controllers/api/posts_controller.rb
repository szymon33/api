module API
  class PostsController < ApplicationController
    before_filter :set_post, only: [:update, :destroy, :like]

    def index
      posts = Post.all
      respond_to do |format|
        format.json { render json: posts, status: 200 }
      end
    end

    def create
      return head 403 if current_user.guest? # forbidden
      post = Post.new(params[:post])
      post.creator = current_user
      if post.save
        render json: post, status: :created, location: [:api, post] # created - 201
        # render nothing: true, status: 204, location: post # no_content
      else
        render json: post.errors, status: 422 # unprocessable_entity
      end
    end

    def update
      return head 403 if not_permitted_user
      if @post.update_attributes(params[:post])
        head :no_content
      else
        render json: @post.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      return head 403 if not_permitted_user
      @post.destroy
      head 204
    end

    def like
      return head 403 if current_user.guest? # forbidden
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

    def not_permitted_user
      !((current_user.user? && @post.creator == current_user) || current_user.admin?)
    end
  end
end
