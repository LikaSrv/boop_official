class AppointmentMailer < ApplicationMailer

  def user_confirmation(appointment)
    @appointment = appointment
    mail(to: @appointment.user.email, subject: "Votre rendez-vous est bien confirmé.")
  end

  def professional_confirmation(appointment)
    @appointment = appointment
    mail(to: @appointment.professional.email, subject: "Vous avez un nouveau rendez-vous.")
  end

end
