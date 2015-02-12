require 'yaml'

class Settings

  attr_accessor :values

  def initialize
    @values = YAML::load_file( File.join(__dir__, '../config.yml') )
  end

  def read attr
    @values[attr]
  end

end
