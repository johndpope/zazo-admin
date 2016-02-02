class Metric::Options
  SESSION_KEY = :metrics_settings
  ATTRIBUTES  = {
    invitation_funnel: [
      { name: :start_date, validate: :date_valid?, default: '' },
      { name: :end_date,   validate: :date_valid?, default: '' }
    ],
    non_marketing_invitations_sent: [
      { name: :start_date, validate: :date_valid?, default: '' },
      { name: :end_date,   validate: :date_valid?, default: '' }
    ],
    invitation_conversion_data: [
      { name: :start_date, validate: :date_valid?, default: '' },
      { name: :end_date,   validate: :date_valid?, default: '' }
    ],
    upload_duplications_data: [
      { name: :senders, validate: :not_empty?, default: nil }
    ]
  }

  attr_reader :metric

  def self.get_by_session(session)
    session[SESSION_KEY]
  end

  def initialize(metric)
    @metric = metric.to_sym
  end

  def get_by_params(params)
    metric_allowed? ?
      { metric => attributes.inject({}) do |memo, attr_data|
        memo.merge value_by_attr_data_params(attr_data, params)
      end || {} } : {}
  end

  private

  def attributes
    ATTRIBUTES[metric]
  end

  def metric_allowed?
    ATTRIBUTES.keys.include? metric
  end

  def attribute_allowed?(name)
    attributes.find do |attr_data|
      attr_data[:name] == name.to_sym
    end ? true : false
  end

  def value_by_attr_data_params(attr_data, params)
    value = params[metric][attr_data[:name].to_s]
    { attr_data[:name] => value && send(attr_data[:validate], value) ? value : attr_data[:default] }
  end

  #
  # validations
  #

  def date_valid?(value)
    Time.parse value
    true
  rescue ArgumentError
    false
  end

  def not_empty?(value)
    !value.empty?
  end
end
