require "sinatra/base"
require "sinatra/reloader" # if development?
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require "haml"
require "pstore"
require 'wiringpi'
require 'rest_client'

class App < Sinatra::Base

  enable :sessions
  register Sinatra::Flash
  set :bind, '0.0.0.0'

  configure :development do
    register Sinatra::Reloader
    also_reload '/models/setting'
  end

  # make sure event listener is stopped and alarm is inactive  with the application
  at_exit do
    settings = Setting.new
    if el_pid = settings.read_attribute( :event_listener_pid )
      begin	
        Process.kill(9, el_pid)
      rescue
      end
    end
    StopAlarm.call( settings )
    settings.update_attribute( :active, false )
  end

  before do
    @settings = Setting.new
  end

  # --- load settings
  get '/' do
    @sound_files = Sound.list_files
    haml :index
  end

  # --- update settings
  post '/' do
    @settings.update( params[:settings] || {} )
    @sound_files = Sound.list_files
    flash[:notice] = 'Settings updated'
    haml :index
  end

  # --- set alarm into ALERT/PAUSED mode
  get '/toggle_activate' do

    if @settings.data[:active]
      AlarmListener.new.stop!
      StopAlarm.call( @settings ) # in case alarm is ringing
      flash[:notice] = 'Alarm is not Active'
    else
      AlarmListener.new.start!
      flash[:notice] = 'Alarm is active'
    end

    @settings.update_attribute( :active, !@settings.data[:active] )
    redirect '/'
  end

  get '/control' do
    haml :control
  end

  post '/api/start' do
    StartAlarm.call( @settings )
  end

  post '/start' do
    flash[:notice] = StartAlarm.call( @settings )
    redirect '/control'
  end

  post '/stop' do
    flash[:notice] = StopAlarm.call( @settings )
    redirect '/control'
  end
end

require_relative 'models/setting'
require_relative 'models/sound'
require_relative 'models/email'
require_relative 'models/alarm_listener'
require_relative 'services/stop_alarm'
require_relative 'services/start_alarm'
