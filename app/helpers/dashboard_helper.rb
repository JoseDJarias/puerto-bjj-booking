module DashboardHelper
  WEEKLY_GREETINGS = [
    {
      title: "¿Todo listo para entrenar, %{name}?",
      subtitle: "Revisa los horarios disponibles y asegura tu lugar en el tatami."
    },
    {
      title: "¡A darlo todo esta semana, %{name}!",
      subtitle: "Tu membresía está activa. Elige tu clase y nos vemos en el tatami."
    },
    {
      title: "¡Qué bueno verte por acá, %{name}!",
      subtitle: "Revisa las clases programadas para esta semana y reserva tu espacio."
    },
    {
      title: "¿Con ganas de tatami, %{name}?",
      subtitle: "No te quedes sin entrenar esta semana. Reserva tu lugar a tiempo."
    },
    {
      title: "¡Semana de entrenamiento, %{name}!",
      subtitle: "Revisa el calendario y asegura tu lugar en las clases."
    },
    {
      title: "¡Nos vemos en el tatami, %{name}!",
      subtitle: "Tu membresía está activa. Elige tu horario y prepárate para entrenar."
    },
    {
      title: "¿Entrenamos esta semana, %{name}?",
      subtitle: "Consulta los cupos disponibles y asegura tu clase."
    },
    {
      title: "¡A sumar horas de tatami, %{name}!",
      subtitle: "La constancia es la clave. Elige tu clase y entrena con el equipo."
    },
    {
      title: "¡Con toda la energía, %{name}!",
      subtitle: "Tu lugar te espera en el tatami. Reserva tus clases de esta semana."
    },
    {
      title: "¡A dar el máximo en cada round, %{name}!",
      subtitle: "Revisa las clases disponibles y ven a entrenar con la academia."
    }
  ].freeze

  def weekly_dashboard_greeting(user)
    week_number = Date.current.cweek
    greeting = WEEKLY_GREETINGS[week_number % WEEKLY_GREETINGS.size]
    name = user&.first_name.presence || "Atleta"

    {
      title: format(greeting[:title], name: name),
      subtitle: greeting[:subtitle]
    }
  end

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