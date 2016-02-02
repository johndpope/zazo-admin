require 'metric/data'

class Metric
  LIST = [
    { name: :messages_failures, type: :messages_failures }
  ]

  class << self
    def all
      LIST.map { |params| build_from_params params }
    end

    def find_by(attribute, value)
      params = LIST.find { |params| params[attribute] == value }
      build_from_params params if params
    end

    private

    def build_from_params(params)
      new params
    end
  end

  attr_reader :name, :type, :data, :options

  def initialize(name:, type:)
    @name = name
    @type = type
    @options = {}
  end

  def data(options = {})
    @options = options
    @data ||= Metric::Data.get_data name, options
  end
end
