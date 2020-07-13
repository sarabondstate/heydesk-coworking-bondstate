class DateAndTimeValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    DateAndTimeValidator::validate(@type, value)
  end

  def self.validate(type, value)
    return false if value.nil?
    begin
      case type.to_s
        when 'Date'
          Date.parse(value)
        when 'Time'
          return Time.parse(value) && !value.match(/^[012][0-9]:[0-5][0-9]$/).nil?
        when 'DateTime'
          DateTime.parse(value)
        else
          return false
      end
      return true
    rescue
      return false
    end
  end

  def self.build(param_description, argument, options, block)
    if argument == Date || argument == Time || argument == DateTime
      self.new(param_description, argument)
    end
  end

  def self.formats type
    formats = {
        Date: 'YYYY-MM-DD',
        Time: 'HH:MM',
        DateTime: '2017-08-31T07:30:21.818Z'
    }
    formats[type.to_s.to_sym]
  end

  def description
    "Must be #{@type}. Format: #{DateAndTimeValidator.formats(@type)}"
  end
end