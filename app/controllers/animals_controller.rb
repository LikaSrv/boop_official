class AnimalsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @animals = Animal.all
    if params[:query].present?
      @animals = Animal.search_by_city(params[:query])
      # sql_subquery = "name ILIKE :query OR species ILIKE :query"
      # @animals = @animals.where(sql_subquery, query: "%#{params[:query]}%")
    end
  end

  def show
    @animal = Animal.find(params[:id])
  end

end
