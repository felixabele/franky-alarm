class StartAlarm

  def self.call settings
    msg = 'alarm started'

    unless settings.alarm_activated?
      if alarm_sound = settings.data[:alarm_sound]
	s = Sound.new( alarm_sound )
        s.play!
        msg << " playing #{alarm_sound}"
      end

      if email_receiver = settings.data[:email_receiver]
        Email.new( email_receiver ).send_start_notice!
      end

      settings.update_attribute( :alarm_activated, true )
    end
    return msg
  end
end
