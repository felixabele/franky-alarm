class AlarmListener

  attr_accessor :settings

  def initialize
    @settings = Setting.new
  end

  def start!
    proc_id = Process.fork do
      button = 1
      gpio = WiringPi::GPIO.new
      gpio.mode button, INPUT

      loop do
        state = gpio.readAll

        if state[button] == 1
          RestClient.post 'http://localhost:4567/api/start'
        end
        sleep 0.3
      end
      Process.exit
    end
    @settings.update_attribute :event_listener_pid, proc_id
  end

  def stop!
    if proc_id = @settings.read_attribute( :event_listener_pid )
      Process.kill(9, proc_id)
    end
  end

end
