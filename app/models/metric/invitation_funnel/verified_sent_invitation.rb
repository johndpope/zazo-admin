class Metric::InvitationFunnel::VerifiedSentInvitation < Metric::InvitationFunnel::RateBase
  TYPE = :rate_base_invitations

  properties total:   'total_verified',
             reduced: 'verified_sent_invitations',
             delay:   'avg_delay_in_hours',
             delay_meas: 'hours'

  titles metric:  'Invites by NMVs',
         total:   'Total NMVs',
         reduced: 'NMVs sent invitations',
         rate:    'Invites per NMV',
         delay:   'Average delay',
         invites_per_verified:    'Invites per NMV',
         no_invite:               'NMV no invite',
         no_invite_six_weeks_old: 'NMV > 6w no invite'

  def invites_per_verified
    count = @data['invitations_count'].to_i
    count_per_user = (count / total.to_f).round 2
    count_per_user = 0 if count_per_user.nan?
    "#{count_per_user} (total #{count})"
  end

  def no_invite
    reduced_with_rate @data['verified_not_invite'].to_i
  end

  def no_invite_six_weeks_old
    reduced = @data['verified_not_invite_more_6_weeks_old'].to_i
    total   = @data['total_verified_more_6_weeks_old'].to_f
    rate    = rate_by_total_reduced total, reduced
    "#{reduced} = #{rate}%"
  end
end
