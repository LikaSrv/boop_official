class ReviewsController < ApplicationController

  def new
    @review = Review.new
    @professional = Professional.find(params[:professional_id])
  end

  def create
    @review = Review.new(review_params)
    @professional = Professional.find(params[:professional_id])
    @appointment = Appointment.find(params[:appointment_id])
    @review = @appointment.build_review(review_params)
    if @review.save!
      @professional.update(rating: ((@professional.rating + @review.rating) / 2).round.to_i)
      redirect_to professional_path(@professional), notice: "Votre commentaire a bien été pris en compte"
    else
      render :new, alert: "Une erreur est survenue. Merci de réessayer plus tard"
    end
  end

  private

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
