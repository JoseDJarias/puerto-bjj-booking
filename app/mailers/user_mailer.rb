class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    @url  = "https://booking.puertojiujitsu.com/login"

    mail(
      to: @user.email_address,
      subject: "¡Bienvenido a Booking Puerto BJJ! Tu cuenta ha sido aprobada"
    )
  end
end