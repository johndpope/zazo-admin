class Metric::Data
  class AttributeMissed < Exception; end
  class AttributeNotAllowed < Exception; end
  class IncorrectAttributeValue < Exception; end
  class MetricNotExist < Exception; end

  def self.get_data(metric_name, params = {})
    Classifier.new([:metric, :data, metric_name]).klass.new(params).generate
  rescue NameError
    raise MetricNotExist, "metric '#{metric_name}' not exist"
  end
end
