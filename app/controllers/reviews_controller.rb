class ReviewsController < ApplicationController

  def new
  end

  def create
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating, :professional_id, :user_id)
  end

end
