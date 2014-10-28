class PostsController < ApplicationController
  
  def index
    posts = Post.all

    respond_to do |format|
      format.json { render json: posts, status: 200 }
    end
  end

  def create
    post = Post.new(params[:post])
    post.user = current_user
    if post.save        
      render json: post, status: 201, location: post # created
      #render nothing: true, status: 204, location: post # no_content
    else
      render json: post.errors, status: 422 # unprocessable_entity
    end
  end

  def update    
    post = Post.find(params[:id])
    if post.update_attributes(params[:post])
      head :no_content
    else
      render json: post.errors, status: 422 # unprocessable_entity   
    end
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    head 204
  end

  def like
    post = Post.find(params[:id])  
    if post.like
      head :no_content
    else
      render json: post.errors, status: 422 # unprocessable_entity   
    end
  end
end

