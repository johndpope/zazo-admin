class Metric::Cell::MessagesFailures < Metric::Cell
  def total_attribute
    model.data[:meta][:total]
  end

  def sections
    @sections ||= data.keys
  end

  def attributes
    @attributes ||= data[:ios_to_ios].keys
  end
end
