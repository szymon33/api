module API::V1
  class CommentsController < ApplicationController
    skip_before_filter :authenticate, only: [:index, :show]
    before_filter :set_comment, except: [:index, :create]
    before_filter :set_post, only: [:create]
    before_filter :user_not_allowed, only: [:update, :destroy]

    def index
      comments = Comment.all
      render json: comments, status: 200
    end

    def create
      @comment = Comment.new(comment_params)
      @comment.post = @post
      @comment.creator = @current_user
      if @comment.save
        render json: @comment, status: 201, location: [:api, :v1, @post] # created
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: @comment, status: 200
    end

    def update
      if @comment.update_attributes(comment_params)
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
      if @comment.like!
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
      return if @current_user.admin?
      return if @current_user.user? && @comment.creator == @current_user

      render_forbidden
    end

    def comment_params
      if @current_user && @current_user.admin?
        params.require(:comment).permit!
      else
        params.require(:comment).permit(:content)
      end
    end
  end
end
