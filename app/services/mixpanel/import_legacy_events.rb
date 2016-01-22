class Mixpanel::ImportLegacyEvents < Mixpanel::ImportBase
  def do
    events = Mixpanel::LegacyData::Events.new(time_from: time_from, time_to: time_to).data
    events.keys.each do |name|
      events[name].each do |event_row|
        e = event_row[:original_event]
        user_mkey = e.initiator_id || e.data['sender_id']
        import_event user_mkey, name, event_row[:data]
      end
    end
  end
end
