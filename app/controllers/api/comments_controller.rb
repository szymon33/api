module API
  class CommentsController < ApplicationController
    skip_before_filter :authenticate, only: [:index, :show]
    before_filter :set_comment, except: [:index, :create]
    before_filter :set_post, only: [:create, :index, :show]
    before_filter :user_not_allowed, only: [:update, :destroy]

    def index
      comments = Comment.all
      respond_to do |format|
        format.json { render json: comments, status: 200, location: [:api, @post] }
      end
    end

    def create
      @comment = Comment.new(params[:comment])
      @comment.post = @post
      @comment.creator = @current_user
      if @comment.save
        render json: @comment, status: 201, location: [:api, @post] # created
      else
        render json: @comment.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: @comment, status: 200, location: [:api, @post]
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
      return if @current_user.admin?
      return if @current_user.user? && @comment.creator == @current_user

      render_forbidden
    end
  end
end
