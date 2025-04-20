class UserMailer < ApplicationMailer
  def test_email(user)
    @user = user
    mail(to: @user.email, subject: "Test Brevo SMTP ✔️")
  end
end
