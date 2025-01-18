require 'icalendar'

class AppointmentMailer < ApplicationMailer

  def user_confirmation(appointment)
    @appointment = appointment
    @ics_data = generate_ics_user(@appointment)

    attachments['boop-rendezvous.ics'] = { mime_type: 'text/calendar', content: @ics_data }
    Rails.logger.info "Attachment data: #{@ics_data}"

    mail(to: @appointment.user.email, subject: "Votre rendez-vous est bien confirmé.", )
  end

  def professional_confirmation(appointment)
    @appointment = appointment
    @ics_data = generate_ics_pro(@appointment)

    attachments['boop-rendezvous.ics'] = { mime_type: 'text/calendar', content: @ics_data }
    Rails.logger.info "Attachment data: #{@ics_data}"

    mail(to: @appointment.professional.email, subject: "Vous avez un nouveau rendez-vous.") do |format|
      format.html { render 'professional_confirmation' }
      format.text { render plain: 'Vous avez un nouveau rendez-vous.' }
    end
  end

  private

  def generate_ics_user(appointment)
    calendar = Icalendar::Calendar.new

    event = Icalendar::Event.new
    event.dtstart = appointment.start_time.in_time_zone("UTC").strftime("%Y%m%dT%H%M%SZ")
    event.dtend = (appointment.start_time + appointment.professional.interval.minutes).in_time_zone("UTC").strftime('%Y%m%dT%H%M%S')
    event.summary = "Rendez-vous avec #{appointment.professional.name}"
    event.url = "http://myboop.fr/"

    calendar.add_event(event)
    calendar.to_ical
  end

  def generate_ics_pro(appointment)
    calendar = Icalendar::Calendar.new

    event = Icalendar::Event.new
    event.dtstart = appointment.start_time.in_time_zone("UTC").strftime('%Y%m%dT%H%M%S')
    event.dtend = (appointment.start_time + appointment.professional.interval.minutes).in_time_zone("UTC").strftime('%Y%m%dT%H%M%S')
    event.summary = "Rendez-vous avec #{appointment.user.first_name}"
    event.url = "http://myboop.fr/"

    calendar.add_event(event)
    calendar.to_ical
  end

end
