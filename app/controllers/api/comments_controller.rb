module API
  class CommentsController < ApplicationController
    before_filter :get_post, only: :create
    before_filter :get_comment, except: :create

    def create
      @comment = Comment.new(params[:comment], post: @post)
      @comment.user = current_user
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
      def get_post() 
        @post = Post.find( params[:post_id] )
      end
      
      def get_comment() 
        @comment = Comment.find( params[:id] )
      end
  end
end
