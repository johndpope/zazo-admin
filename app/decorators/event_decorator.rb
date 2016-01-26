class EventDecorator < Draper::Decorator
  delegate_all

  def triggered_at
    h.content_tag :span, object.triggered_at.to_datetime.to_s(:rfc822), title: h.time_ago_in_words(object.triggered_at)
  end

  def name
    object.name && object.name.join(':') || ''
  end

  def data
    h.content_tag :pre, JSON.neat_generate(object.data)
  end

  def raw_params
    h.content_tag :pre, JSON.neat_generate(object.raw_params)
  end
end
