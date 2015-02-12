class Sound

  attr_accessor :file, :player, :app_db

  def initialize file
    @file = file
  end

  def self.list_files
     Dir.glob('media/*.mp3')
  end

  # --- plays audio and stores
  def play!
    if @file
      fork do
        begin
          system "play #{@file}" # exec
        rescue
  	      puts "error playing sound"
        end
      end
    end
  end

  # --- gets pid from DB and kills audio player process
  def stop!
    system "pkill -f play"
  end
end
