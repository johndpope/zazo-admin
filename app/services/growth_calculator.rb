class GrowthCalculator
  class OptionMissing < StandardError; end

  attr_reader :nmv, :invitees

  def initialize(options)
    @nmv_invite_rate    = options[:nmv_invite_rate]
    @invites_per_nmv    = options[:invites_per_nmv]
    @loop_delay_in_days = options[:loop_delay_in_days]
    @nmr_per_invite     = options[:nmr_per_invite]
    @nmv_per_nmr        = options[:nmv_per_nmr]
    check_options
    @nmv      = 0
    @invitees = 0
  end

  def growth_after_days(days)
    gain = @nmv_invite_rate *
           @invites_per_nmv *
           @nmr_per_invite *
           @nmv_per_nmr
    return @nmv if gain < 1

    @nmv = 1
    @invitees = 1
    (days / @loop_delay_in_days).times do
      @invitees *= gain
      @nmv += @invitees
    end
    @nmv
  end

  private

  def check_options
    instance_variables.each do |var|
      fail OptionMissing, var if instance_variable_get(var).nil?
    end
  end
end
