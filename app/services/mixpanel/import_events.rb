class Mixpanel::ImportEvents < Mixpanel::ImportBase
  attr_reader :events

  def do
    events.data.each { |e| import_event e[:user], events.desc[:name], e[:data] }
  end

  private

  def set_additional_params(params)
    @events = params[:events]
  end
end
