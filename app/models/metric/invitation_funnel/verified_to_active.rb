class Metric::InvitationFunnel::VerifiedToActive < Metric::InvitationFunnel::RateBase
  properties total:   'total_verified',
             reduced: 'verified_that_active',
             delay:   'avg_delay_in_minutes',
             delay_meas: 'minutes'

  titles metric:  'NMV becoming Active',
         total:   'Total NMVs',
         reduced: 'Active NMVs',
         rate:    'Becoming active rate',
         delay:   'Average delay'
end
