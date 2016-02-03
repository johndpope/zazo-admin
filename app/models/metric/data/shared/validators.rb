module Metric::Data::Shared::Validators
  def validate_date_string
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
