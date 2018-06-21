class BoardController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  # before_action :set_post, except: [:index, :new, :create]
  def index
    @posts = Post.all
    puts current_user
  end

  def show
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
  end
  
  def update
    @post.title = params[:title]
    @post.contents = params[:contents]
    @post.save
    redirect_to "/board/#{@post.id}"
  end
  
  def destroy
    @post.destroy
    redirect_to "/boards"
  end
  
  def set_post
    @post = Post.find(params[:id])
  end
end
