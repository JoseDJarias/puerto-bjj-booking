module DashboardHelper
  def smart_countdown(schedule)
    return "-" if schedule.nil?

    now = Time.current
    start_t = schedule.starts_at
    end_t = start_t + schedule.duration_minutes.minutes

    if now < start_t
      # Future Class
      diff = (start_t - now).to_i
      if diff > 1.day
        "#{(diff / 1.day).to_i} días"
      elsif diff > 1.hour
        "#{diff / 3600}h #{(diff % 3600) / 60}m"
      else
        tag.span("#{diff / 60} min", class: "text-orange-600 animate-pulse")
      end
    elsif now >= start_t && now <= end_t
      tag.span("En curso", class: "text-green-600 font-bold")
    else
      "Terminada"
    end
  end
end