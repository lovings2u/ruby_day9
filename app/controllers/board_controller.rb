class BoardController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
  end
  
  def create
    post = Post.new
    post.title = params[:title]
    post.contents = params[:contents]
    post.save
    
    redirect_to "/board/#{post.id}"
  end

  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    post = Post.find(params[:id])
    post.title = params[:title]
    post.contents = params[:contents]
    post.save
    redirect_to "/board/#{post.id}"
  end
  
  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to "/boards"
  end
end
