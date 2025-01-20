class UsersController < ApplicationController

  def show
    @user = current_user
    @appointments = Appointment.where(user_id: @user.id)
    @pets = Pet.where(user_id: @user.id)
  end

  def edit
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :photo)
  end

end
