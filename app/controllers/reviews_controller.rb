class ReviewsController < ApplicationController

  def new
    @review = Review.new
    @professional = Professional.find(params[:professional_id])
  end

  def create
    @professional = Professional.find(params[:professional_id])
    @review = @professional.reviews.build(review_params)
    @review.user = current_user
    update_professional_rating
    if @review.save!
      redirect_to professional_path(@professional), notice: "Votre commentaire a bien été pris en compte"
    else
      flash.now[:alert] = @review.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def update_professional_rating
    new_rating = @professional.reviews.average(:rating).to_f.round
    @professional.update(rating: new_rating)
  end

  def review_params
    params.require(:review).permit(:content, :rating, :professional_id, :user_id)
  end
end
