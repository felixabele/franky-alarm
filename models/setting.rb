class Setting

  ATTRIBUTES = [:active, :alarm_sound, :email_receiver, :output_pin, :input_pin]

  attr_accessor :data, :ps_store

  def initialize db_name="franky_alarm.settings"
    @data ||= {}
    @ps_store = PStore.new( db_name )
    @ps_store.transaction do
      ATTRIBUTES.each{|att| @data[att] = @ps_store[att] }
    end
  end

  def update values={}
    @ps_store.transaction do
      ATTRIBUTES.each do |att|
        @data[att] = values[att]
        @ps_store[att] = values[att]
      end
    end
  end

  def update_attribute att, value
    @ps_store.transaction do
      @data[att] = value
      @ps_store[att] = value
    end
  end

  def read_attribute att
    @ps_store.transaction do
      @ps_store[att]
    end
  end

  def alarm_activated?
    self.read_attribute(:alarm_activated) === true
  end
end
