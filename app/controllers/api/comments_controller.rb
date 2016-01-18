module API
  class CommentsController < ApplicationController
    before_filter :set_post, only: :create
    before_filter :set_comment, except: :create

    def create
      return head :forbidden if current_user.guest?
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
      return head :forbidden unless permitted_user?
      if @comment.update_attributes(params[:comment])
        head :no_content
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      return head :forbidden unless permitted_user?
      @comment.destroy
      head 204
    end

    def like
      return head :forbidden if current_user.guest?
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

    def permitted_user?
      (current_user.user? && @comment.creator == current_user) || current_user.admin?
    end
  end
end
