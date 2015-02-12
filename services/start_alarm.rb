class StartAlarm

  def self.call app_db
    msg = 'alarm started'

    unless app_db.alarm_activated?
      if alarm_sound = app_db.data[:alarm_sound]
        s = Sound.new( alarm_sound )
        s.play!
        msg << " playing #{alarm_sound}"
      end

      if email_receiver = app_db.data[:email_receiver]
        Email.new( email_receiver ).send_start_notice!
      end

      app_db.update_attribute( :alarm_activated, true )
    end
    return msg
  end
end
