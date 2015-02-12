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
    puts Settings.new.read('smtp')
    unless @receiver.blank?
      Pony.mail({
        :to => @receiver,
        :via => :smtp,
        :body => body,
        :subject => subject,
        :via_options => Settings.new.read(:smtp)
      })
    end
  end

end
