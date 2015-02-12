require "sinatra/base"
require "sinatra/reloader"
require "sinatra/flash"
require "sinatra/redirect_with_flash"
require "haml"
require "pstore"
require "wiringpi"
require "rest_client"

class App < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  set :bind, '0.0.0.0'

  configure :development do
    register Sinatra::Reloader
    also_reload '/models/app_db'
  end

  # ----------------------
  # --- Stopping the server
  # ----------------------
  # make sure event listener is stopped and alarm is inactive  with the application
  at_exit do
    app_db = AppDb.new
    if el_pid = app_db.read_attribute( :event_listener_pid )
      begin
        Process.kill(9, el_pid)
      rescue
      end
    end
    StopAlarm.call( app_db )
    app_db.update_attribute( :active, false )
  end

  before do
    @app_db = AppDb.new
  end

  # ----------------------
  # --- Show Settings
  # ----------------------
  get '/' do
    @sound_files = Sound.list_files
    haml :index
  end

  # ----------------------
  # --- update Settings
  # ----------------------
  post '/' do
    @app_db.update( params[:app_db] || {} )
    @sound_files = Sound.list_files
    flash[:notice] = 'Settings updated'
    haml :index
  end

  # ----------------------
  # --- set alarm into ALERT/PAUSED mode
  # ----------------------
  get '/toggle_activate' do

    if @app_db.data[:active]
      AlarmListener.new.stop!
      StopAlarm.call( @app_db ) # in case alarm is ringing
      flash[:notice] = 'Alarm is not Active'
    else
      AlarmListener.new.start!
      flash[:notice] = 'Alarm is active'
    end

    @app_db.update_attribute( :active, !@app_db.data[:active] )
    redirect '/'
  end

  # ----------------------
  # --- Start or Stop the Alarm here (for Testing)
  # ----------------------
  get '/control' do
    haml :control
  end

  # ----------------------
  # --- This is called from AlarmListener
  # ----------------------
  post '/api/start' do
    StartAlarm.call( @app_db )
  end

  # ----------------------
  # --- Manually start Alarm
  # ----------------------
  post '/start' do
    flash[:notice] = StartAlarm.call( @app_db )
    redirect '/control'
  end

  # ----------------------
  # --- Manually stop Alarm
  # ----------------------
  post '/stop' do
    flash[:notice] = StopAlarm.call( @app_db )
    redirect '/control'
  end
end

require_relative 'models/app_db'
require_relative 'models/sound'
require_relative 'models/email'
require_relative 'models/alarm_listener'
require_relative 'models/settings'
require_relative 'services/stop_alarm'
require_relative 'services/start_alarm'
