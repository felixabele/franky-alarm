class StopAlarm

  def self.call settings

    if settings.alarm_activated?
      Sound.new( nil ).stop!

      if email_receiver = settings.data[:email_receiver]
        Email.new( email_receiver ).send_stop_notice!
      end

      settings.update_attribute( :alarm_activated, false )
    end

    return "Alarm Stopped"
  end
end
