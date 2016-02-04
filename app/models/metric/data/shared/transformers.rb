module Metric::Data::Shared::Transformers
  def string_to_time
    -> (value) do
      Time.parse value
    end
  end
end
