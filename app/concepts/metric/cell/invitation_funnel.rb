class Metric::Cell::InvitationFunnel < Metric::Cell
  def raw_data
    data(options)
  end

  def mapped_data
    @mapped ||= raw_data.keys.map do |key|
      klass = "Metric::InvitationFunnel::#{key.to_s.classify}".safe_constantize
      klass.nil? ? { name: key, data: data[key] } : klass.new(data[key])
    end
  end
end
