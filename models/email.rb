class Email

  attr_accessor :receiver

  def initialize receiver
    @receiver = receiver
  end

  def send_start_notice!
    self.send(
      'Alarm has Started!',
      "Alarm started on #{Time.now}")
  end

  def send_stop_notice!
    self.send(
      'Alarm has Stopped',
      "Alarm stoppen on #{Time.now}")
  end

  def send subject, body
    unless @receiver.blank?
      Pony.mail({
        :to => @receiver,
        :via => :smtp,
        :body => body,
        :subject => subject,
        :via_options => {
          :address              => 'smtp.gmail.com',
          :port                 => '587',
          :enable_starttls_auto => true,
          :user_name            => 'felix.abele@gmail.com',
          :password             => 'pera3gera',
          :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
          :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
        }
      })
    end
  end

end
