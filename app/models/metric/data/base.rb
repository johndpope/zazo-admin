class Metric::Data::Base
  extend ActiveModel::Callbacks

  attr_reader :incoming_attributes
  define_model_callbacks :initialize

  def self.allowed_attributes
    []
  end

  def initialize(attributes)
    @incoming_attributes = attributes
    set_attributes
    run_callbacks :initialize
  end

  protected

  def allowed_attributes
    self.class.allowed_attributes
  end

  def set_attributes
    allowed_attributes.each do |attr, settings|
      if incoming_attributes[attr]
        set_attribute attr, settings
      else
        raise Metric::Data::AttributeMissed, "#{attr} attribute is missed" unless settings[:optional]
      end
    end
  end

  def set_attribute(attr, settings)
    value = settings[:transform].kind_of?(Proc) ?
      settings[:transform].call(incoming_attributes[attr]) : incoming_attributes[attr]
    self.instance_variable_set :"@#{attr}", value
    self.class_eval { attr_reader attr }
  end
end
