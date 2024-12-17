class AnimalsController < ApplicationController

  def index
    @animals = Animal.all
    if params[:query].present?
      sql_subquery = "name ILIKE :query OR species ILIKE :query"
      @animals = @animals.where(sql_subquery, query: "%#{params[:query]}%")
    end
  end

  def show
    @animal = Animal.find(params[:id])
  end

end
