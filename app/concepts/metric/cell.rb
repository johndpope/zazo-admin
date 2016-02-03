class Metric::Cell < Cell::Concept
  extend ActiveModel::Callbacks

  include ActionView::RecordIdentifier
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::NumberHelper
  include Chartkick::Helper

  define_model_callbacks :initialize

  def self.layout
    :layout
  end

  property :name, :type

  def initialize(*args)
    super
    run_callbacks :initialize
  end

  def show
    view = self.class.view rescue "_#{type}"
    render layout: self.class.layout, view: view
  rescue Cell::TemplateMissingError
    render layout: self.class.layout, view: :show
  end

  private

  def data(options = {})
    data = model.data options
    data.kind_of?(Hash) && data.key?(:data) ? data[:data] : data
  end

  def options
    @options[:options][type] || {} rescue {}
  end

  #
  # metrics
  #

  def invitation_funnel(subject)
    @data ||= data options
    return @data if subject == :raw
    @mapped ||= @data.keys.map do |key|
      klass = "Metric::InvitationFunnel::#{key.classify}".safe_constantize
      klass.nil? ? { name: key, data: @data[key] } : klass.new(@data[key])
    end
  end

  def non_marketing_users_data
    @metric ||= Metric::NonMarketingUsersData.new data(options), options
  end

  def upload_duplications(*)
    mkeys = data.map { |i| i['sender_id'] }
    new_data = User.where(mkey: mkeys).group(:device_platform).count
    pie_chart new_data, colors: %w(grey green blue), id: chart_id
  end

  def aggregated(*)
    pie_chart data.except(total_attribute), id: chart_id
  end

  #
  # helpers
  #

  def title
    name.to_s.titleize
  end

  def chart_id
    "chart-#{SecureRandom.hex}"
  end
end
