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
      respond_to do |format|
        format.json { render json: { success: true, message: "Avis ajouté avec succès", review: @review.as_json(include: { user: { only: [:first_name, :last_name] } })
        }, status: :created }
        format.html { redirect_to professional_path(@professional), notice: "Avis ajouté avec succès." }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @review.errors.full_messages }, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
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
