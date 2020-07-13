class ArrayOfIntsValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    ## The array can be empty (in rails POST it means it will be an array with an empty string)
    return true if @type == :array_of_ints_or_empty and (value.nil? or value.empty? or value=='' or value==[''])
    ## The array should be with integers
    return false unless value.kind_of?(Array)
    value.all? do |v|
      v.to_i.to_s == v.to_s
    end
  end

  def self.build(param_description, argument, options, block)
    if argument == :array_of_ints || argument == :array_of_ints_or_empty
      self.new(param_description, argument)
    end
  end

  def description
    'Must be an array of integers.'
  end
end