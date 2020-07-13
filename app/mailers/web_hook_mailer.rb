class WebHookMailer < ApplicationMailer
  def import_done(message)
    subject = "Mosson CSV import result"
    @body = message.html_safe
    mail(to: "dev@houseofcode.io", subject: subject)
  end

  def failed_parsing(message)
    subject = "Mosson CSV import failure"
    @body = message.html_safe
    mail(to: "dev@houseofcode.io", subject: subject)
  end
end
