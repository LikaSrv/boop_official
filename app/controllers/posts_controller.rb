class PostsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @posts = Post.all
  end

  def show
    @post=Post.find_by!(slug: params[:slug])
    @content_blocks = @post.content_blocks.order(:position)
  end

end
