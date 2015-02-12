class StopAlarm

  def self.call app_db

    if app_db.alarm_activated?
      Sound.new( nil ).stop!

      if email_receiver = app_db.data[:email_receiver]
        Email.new( email_receiver ).send_stop_notice!
      end

      app_db.update_attribute( :alarm_activated, false )
    end

    return "Alarm Stopped"
  end
end
