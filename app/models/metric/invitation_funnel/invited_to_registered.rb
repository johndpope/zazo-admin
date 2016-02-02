class Metric::InvitationFunnel::InvitedToRegistered < Metric::InvitationFunnel::RateBase
  properties total:   'total_invited',
             reduced: 'invited_that_register',
             delay:   'avg_delay_in_hours',
             delay_meas: 'hours'

  titles metric:  'Invited becoming registered',
         total:   'Total invited',
         reduced: 'Invited that registered',
         rate:    'Becoming registered rate',
         delay:   'Average delay'
end
