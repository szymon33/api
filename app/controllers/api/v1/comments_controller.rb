module API::V1
  class CommentsController < ApplicationController
    skip_before_filter :authenticate, only: [:index, :show]
    before_filter :verify_authorized, except: [:index, :create]

    def index
      authorize Comment
      comments = Comment.all
      render json: comments, status: 200
    end

    def create
      authorize Comment
      comment = Comment.new(comment_params)
      comment.post = post
      comment.creator = @current_user
      if comment.save
        render json: comment, status: 201, location: [:api, :v1, post] # created
      else
        render json: comment.errors, status: 422 # unprocessable_entity
      end
    end

    def show
      render json: comment, status: 200
    end

    def update
      if comment.update_attributes(comment_params)
        head :no_content
      else
        render json: comment.errors, status: 422 # unprocessable_entity
      end
    end

    def destroy
      comment.destroy
      head 204
    end

    def like
      if comment.like!
        head :no_content
      else
        render json: comment.errors, status: 422 # unprocessable_entity
      end
    end

    private

    def post
      @post ||= Post.find(params[:post_id])
    end

    def comment
      @comment ||= Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:title, :content)
    end

    def verify_authorized
      authorize comment
    end
  end
end
