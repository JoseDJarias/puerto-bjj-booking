module DashboardHelper
  def smart_countdown(schedule)
    return "-" if schedule.nil?

    seconds_left = schedule.starts_at - Time.current

    case
    when seconds_left > 1.day
      # Más de 24 horas: Retorna días simples
      "#{(seconds_left / 1.day).to_i} días"

    when seconds_left > 1.hour
      # Menos de un día: Retorna horas y minutos (Ej: 4h 15m)
      hours = (seconds_left / 1.hour).to_i
      minutes = ((seconds_left % 1.hour) / 1.minute).to_i
      "#{hours}h #{minutes}m"

    when seconds_left > 0
      # Menos de una hora: Retorna minutos con alerta visual (HTML safe)
      minutes = (seconds_left / 1.minute).to_i
      tag.span("#{minutes} min", class: "text-orange-600 animate-pulse")

    else
      # Ya pasó o es ahora mismo
      tag.span("En curso", class: "text-green-600")
    end
  end
end