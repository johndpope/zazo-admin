module Metric::Data::Shared::GroupableByTimeFrame
  extend ActiveSupport::Concern

  attr_accessor :group_by
  included { after_initialize :set_group_by }

  protected

  def set_group_by
    @group_by = incoming_attributes.fetch(:group_by, :day).try :to_sym
    unless Groupdate::FIELDS.include? group_by
      raise Metric::Data::IncorrectAttributeValue, "#{group_by} is not allowed value for 'group_by' attribute"
    end
  end

  def reduce_by_users(data)
    data.each_with_object({}) do |(key, value), memo|
      next if value.zero?
      time_frame, user_id = key
      memo[time_frame] ||= Set.new
      memo[time_frame] << user_id
    end
  end
end
