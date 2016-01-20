module API
  class CommentsController < ApplicationController
    before_filter :set_post, only: :create
    before_filter :set_comment, except: :create
    before_filter :user_not_allowed, only: [:update, :destroy]
    before_filter :guest_not_allowed, except: [:show]

    def create
      @comment = Comment.new(params[:comment], post: @post)
      @comment.creator = current_user
      if @comment.save
        render json: @comment, status: 201, location: [:api, @post] # created
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: @comment, status: 200
    end

    def update
      if @comment.update_attributes(params[:comment])
        head :no_content
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      @comment.destroy
      head 204
    end

    def like
      if @comment.like
        head :no_content
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    private

    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def user_not_allowed
      unless (current_user.user? && @comment.creator == current_user) || current_user.admin?
        render_forbidden
      end
    end
  end
end
