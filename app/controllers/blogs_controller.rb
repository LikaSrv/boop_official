class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @blogs = Blog.all.order(created_at: :desc)
  end

  def show
    @blog = Blog.find(params[:id])
  end

end
