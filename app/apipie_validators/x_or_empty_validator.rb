class XOrEmptyValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, parser, description)
    super(param_description)
    @parser = parser
    @description = description
  end

  def validate(value)
    return value.empty? || @parser.call(value)
  end

  def self.build(param_description, argument, options, block)
    if argument == :number_or_empty
      return self.new(param_description, Proc.new {|value| value.to_i.to_s == value.to_s}, 'Must be a number or empty.')
    end
    if argument == :date_or_empty
      return self.new(param_description, Proc.new {|value| DateAndTimeValidator.build(param_description, Date, nil, nil).validate(value)}, 'Must be a date or empty.')
    end
    if argument == :time_or_empty
      return self.new(param_description, Proc.new {|value| DateAndTimeValidator.build(param_description, Time, nil, nil).validate(value)}, 'Must be a time or empty.')
    end
  end

  def description
    @description
  end
end