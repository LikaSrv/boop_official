class ReviewsController < ApplicationController

  def new
    @review = Review.new
    @appointment = Appointment.find(params[:appointment_id])
    @professional = Professional.find(params[:professional_id])
  end

  # def create
  #   @review = @appointment.reviews.build(review_params)
  #   if @review.save!
  #     redirect_to professional_path(@professional), notice: "Votre commentaire a bien été pris en compte"
  #   else
  #     render :new, alert: "Une erreur est survenue. Merci de réessayer plus tard."
  #   end
  # end

  private

  def review_params
    params.require(:review).permit(:content, :rating, :professional_id, :user_id)
  end
end
