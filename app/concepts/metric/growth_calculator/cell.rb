class Metric::GrowthCalculator::Cell < Cell::Concept
  def show
    render
  end

  private

  #
  # attributes
  #

  def nmv_sent_invite_rate
    rate 'verified_sent_invitations', 'total_verified', 'verified_sent_invitations'
  end

  def total_invites_per_nmv
    model['average_invitations_count'].find do |row|
      row['week_after_verified'] == 'total'
    end['avg_invitations_count'].to_f.round 2
  end

  def invited_to_registered_rate
    rate 'invited_to_registered', 'total_invited', 'invited_that_register'
  end

  def nmr_to_nmv_rate
    rate 'registered_to_verified', 'total_registered', 'registered_that_verify'
  end

  def delay_in_days
    [ { keys: %w(verified_sent_invitations avg_delay_in_hours), convert: -> (val) { val.to_f / 24 } },
      { keys: %w(invited_to_registered avg_delay_in_hours),     convert: -> (val) { val.to_f / 24 } },
      { keys: %w(registered_to_verified avg_delay_in_minutes),  convert: -> (val) { val.to_f / 24 / 60 } }
    ].inject(0) { |sum, row| sum + row[:convert].call(model[row[:keys][0]][row[:keys][1]]) }.round 2
  end

  #
  # helpers
  #

  def rate(category_key, total_key, count_key)
    total = model[category_key] ? model[category_key][total_key] : 1
    count = model[category_key] ? model[category_key][count_key] : 0
    rate = (count.to_f / total.to_f)
    rate.nan? ? 0 : rate.round(2)
  end
end
