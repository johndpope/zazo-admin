class Metric::Data::Base
  extend ActiveModel::Callbacks
  extend Metric::Data::Shared::Validators

  attr_reader :incoming_attributes
  define_model_callbacks :initialize

  def self.allowed_attributes
    []
  end

  def initialize(incoming_attributes = {})
    @incoming_attributes = incoming_attributes
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
        set_attribute attr, attribute_value(attr)
      elsif settings.key? :default
        set_attribute attr, settings[:default]
      elsif !settings[:optional]
        raise Metric::Data::AttributeMissed, "#{attr} attribute is missed"
      end
    end
  end

  def set_attribute(attr, value)
    self.instance_variable_set :"@#{attr}", value
    self.class_eval { attr_reader attr }
  end

  def attribute_value(attr)
    value = allowed_attributes[attr][:transform].kind_of?(Proc) ?
      allowed_attributes[attr][:transform].call(incoming_attributes[attr]) : incoming_attributes[attr]
    valid?(attr, value) && allowed_attributes[attr][:default] ? value : allowed_attributes[attr][:default]
  end

  def valid?(attr, value)
    allowed_attributes[attr][:validate].kind_of?(Proc) ?
      allowed_attributes[attr][:validate].call(value) : true
  end

  def run_raw_query_on_events(query)
    Event.connection.select_all(query)
  end
end
