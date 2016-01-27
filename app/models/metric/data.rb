class Metric::Data
  class AttributeMissed < Exception; end
  class AttributeNotAllowed < Exception; end
  class IncorrectAttributeValue < Exception; end

  class DataHash < Hash
    include Hashie::Extensions::IndifferentAccess
  end

  def self.get_data(metric_name, params = {})
    DataHash[Classifier.new([:metric, :data, metric_name]).klass.new(params).generate]
  end
end
