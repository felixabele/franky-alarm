class AlarmListener

  attr_accessor :settings

  def initialize
    @settings = Setting.new
  end

  def start!
    proc_id = Process.fork do
      listen_pin = @settings.data[:input_pin].to_i
      activate_pin = @settings.data[:output_pin].to_i
      gpio = WiringPi::GPIO.new
      gpio.mode( listen_pin, INPUT) if listen_pin > 0

      if activate_pin > 0
        gpio.mode( activate_pin, OUTPUT)
        gpio.write activate_pin, 0
      end

      loop do
	puts "outp"
        state = gpio.readAll

        if state[listen_pin] == 0
          puts RestClient.post 'http://localhost:4567/api/start', {}
          gpio.write( activate_pin, 1 ) if activate_pin > 0
        end
        sleep 0.3
      end
      Process.exit
    end
    @settings.update_attribute :event_listener_pid, proc_id
  end

  def stop!
    if proc_id = @settings.read_attribute( :event_listener_pid )
      begin
        Process.kill(9, proc_id)
      rescue Exception => e
        puts e
      end
    end
  end

end
