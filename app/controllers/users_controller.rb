class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @appointments = Appointment.where(user_id: @user.id)
    @pets = Pet.where(user_id: @user.id)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.first_name = user_params[:first_name]
    @user.last_name = user_params[:last_name]
    @user.photo.attach(user_params[:photo])
    if @user.update!
      redirect_to user_path(@user)
    else
      render new, alert: "Erreur lors de la modification de votre profil"
    end

  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :photo)
  end

end
