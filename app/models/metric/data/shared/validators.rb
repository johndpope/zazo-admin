module Metric::Data::Shared::Validators
  def string_contains_date?
    -> (value) do
      begin
        Time.parse value
        true
      rescue ArgumentError
        false
      end
    end
  end
end
