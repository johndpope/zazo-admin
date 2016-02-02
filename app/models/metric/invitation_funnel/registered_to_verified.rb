class Metric::InvitationFunnel::RegisteredToVerified < Metric::InvitationFunnel::RateBase
  properties total:   'total_registered',
             reduced: 'registered_that_verify',
             delay:   'avg_delay_in_minutes',
             delay_meas: 'minutes'

  titles metric:  'NMR becoming verified',
         total:   'Total NMRs',
         reduced: 'Verified NMRs',
         rate:    'Becoming verified rate',
         delay:   'Average delay'
end
