class ApplicationMailer < ActionMailer::Base
  default from: "Puerto BJJ <academia@booking.puertojiujitsu.com>",
          reply_to: "infopuertobjj@gmail.com"
  layout "mailer"
end
