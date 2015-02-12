class AlarmListener

  attr_accessor :app_db

  def initialize
    @app_db = AppDb.new
  end

  def start!
    proc_id = Process.fork do
      listen_pin = @app_db.data[:input_pin].to_i
      activate_pin = @app_db.data[:output_pin].to_i
      gpio = WiringPi::GPIO.new
      gpio.mode( listen_pin, INPUT) if listen_pin > 0

      if activate_pin > 0
        gpio.mode( activate_pin, OUTPUT)
        gpio.write activate_pin, 0
      end

      loop do
        state = gpio.readAll

        if state[listen_pin] == 0
          RestClient.post 'http://localhost:4567/api/start', {}
          gpio.write( activate_pin, 1 ) if activate_pin > 0
        end
        sleep 0.3
      end
      Process.exit
    end
    @app_db.update_attribute :event_listener_pid, proc_id
  end

  def stop!
    if proc_id = @app_db.read_attribute( :event_listener_pid )
      begin
        Process.kill(9, proc_id)
      rescue Exception => e
        puts e
      end
    end
  end

end
