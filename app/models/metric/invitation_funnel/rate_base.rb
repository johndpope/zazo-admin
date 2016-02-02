module Metric::InvitationFunnel
  class RateBase
    TYPE = :rate_base

    class << self
      attr_writer :titles, :properties

      def properties(props = {})
        props.empty? ? @properties : self.properties = props
      end

      def titles(props = {})
        props.empty? ? @titles : self.titles = props
      end

      def property(key)
        properties[key]
      end
    end

    def initialize(data)
      @data = data
    end

    def title(key)
      self.class.titles[key]
    end

    def total
      @data[self.class.property :total].to_i
    end

    def reduced
      reduced_with_rate @data[self.class.property :reduced].to_i
    end

    def delay
      @data[self.class.property :delay]
    end

    def delay_meas
      self.class.property :delay_meas
    end

    protected

    def rate_by_total_reduced(total, reduced)
      rate = reduced * 100.0 / total
      rate.nan? ? 0 : rate.round(2)
    end

    def rate_by_total(reduced)
      rate_by_total_reduced total, reduced
    end

    def reduced_with_rate(reduced)
      "#{reduced} = #{rate_by_total reduced}%"
    end
  end
end
