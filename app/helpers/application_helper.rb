module ApplicationHelper
  def status_tag(status)
    content_tag :span, status, class: ['status', status]
  end

  def human_device_platform(platform)
    t(platform, scope: :device_platforms)
  end

  def part_and_percentage(total, part)
    number = total.zero? ? 0 : part * 100.0 / total
    percent = number_to_percentage(number, precision: 2)
    "#{part} (#{percent})"
  end
end
