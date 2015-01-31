=begin
  require './app.rb'
  sound_files = Sound.list_files
  s = Sound.new( sound_files.first )
  s.play!
=end

class Sound

  attr_accessor :file, :player, :settings

  def initialize file
    @file = file
    @settings = Setting.new
  end

  def self.list_files
     Dir.glob('media/*.mp3')
  end

  # --- plays audio and stores
  def play!
    fork do
      system "play #{@file}" # exec
    end
  end

  # --- gets pid from DB and kills audio player process
  def stop!
    system "pkill -f play"
  end
end
