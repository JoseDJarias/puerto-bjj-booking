namespace :audit do
  desc "Audit application endpoints for N+1 queries and performance bottlenecks"
  task queries: :environment do

    puts "\n" + "=" * 80
    puts " 🔍 PUERTO BJJ - N+1 & DATABASE QUERY AUDITOR".center(80)
    puts "=" * 80 + "\n"

    # Ensure Bullet is enabled
    Bullet.enable = true if defined?(Bullet)
    Bullet.raise = false if defined?(Bullet) # Collect instead of raising for comprehensive audit report

    # Test routes definition: [Role, Label, HTTP Method, Path]
    routes_to_audit = [
      # Public / Unauthenticated
      [:public, "Iniciar Sesión", :get, "/session/new"],
      [:public, "Registro", :get, "/registration/new"],
      [:public, "Contacto", :get, "/contacto"],
      [:public, "Dog Fights Info", :get, "/dog-fights"],

      # Student / Authenticated
      [:student, "Dashboard Alumno", :get, "/"],
      [:student, "Mi Membresía", :get, "/mi-membresia"],
      [:student, "Historial Membresía", :get, "/mi-membresia/historial"],
      [:student, "Catálogo Tienda", :get, "/catalogo"],
      [:student, "Mis Pedidos", :get, "/mis-pedidos"],

      # Admin
      [:admin, "Admin - Dashboard", :get, "/admin/dashboard/index"],
      [:admin, "Admin - Usuarios", :get, "/admin/users"],
      [:admin, "Admin - Horarios de Clases", :get, "/admin/class_schedules"],
      [:admin, "Admin - Membresías", :get, "/admin/membresias"],
      [:admin, "Admin - Planes", :get, "/admin/planes"],
      [:admin, "Admin - Paquetes", :get, "/admin/paquetes"],
      [:admin, "Admin - Catálogo Productos", :get, "/admin/catalogo"],
      [:admin, "Admin - Pedidos Productos", :get, "/admin/pedidos"]
    ]

    # Setup actors
    admin_user = User.find_by(email_address: "admin@puertojiujitsu.com") || User.find_by(role: :admin) || User.first
    student_user = User.find_by(role: :student) || User.where.not(id: admin_user&.id).first || admin_user

    # Add single product and order routes if available
    if (sample_product = Product.first)
      routes_to_audit << [:student, "Detalle de Producto", :get, "/catalogo/#{sample_product.id}"]
      routes_to_audit << [:admin, "Admin - Detalle de Producto", :get, "/admin/catalogo/#{sample_product.id}"]
      routes_to_audit << [:admin, "Admin - Editar Producto", :get, "/admin/catalogo/#{sample_product.id}/edit"]
    end

    if (sample_order = ProductOrder.first)
      routes_to_audit << [:student, "Detalle de Mi Pedido", :get, "/mis-pedidos/#{sample_order.id}"]
      routes_to_audit << [:admin, "Admin - Detalle de Pedido", :get, "/admin/pedidos/#{sample_order.id}"]
    end

    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host! "localhost"

    results = []
    total_warnings = 0

    routes_to_audit.each do |role, label, method, path|
      # Authenticate appropriate user
      session.reset!
      session.host! "localhost"
      user = role == :admin ? admin_user : (role == :student ? student_user : nil)
      if user
        db_session = user.sessions.create!
        ActionDispatch::TestRequest.create.cookie_jar.tap do |jar|
          jar.signed[:session_id] = db_session.id
          session.cookies["session_id"] = jar[:session_id]
        end
      end

      # Track SQL queries
      queries = []
      duplicate_queries = Hash.new(0)

      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
        sql = payload[:sql].to_s.strip
        unless payload[:name] == "SCHEMA" || sql =~ /\A(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE SAVEPOINT)\b/i || sql =~ /schema_migrations/i
          queries << sql
          # Clean SQL variables to detect duplicate query patterns
          normalized_sql = sql.gsub(/\d+/, "?").gsub(/'[^']*'/, "?")
          duplicate_queries[normalized_sql] += 1
        end
      end

      Bullet.start_request if defined?(Bullet)

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      session.public_send(method, path)
      status_code = session.response.status
      end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      duration_ms = ((end_time - start_time) * 1000).round(1)

      bullet_warnings = []
      if defined?(Bullet) && Bullet.notification?
        Bullet.notification_collector.collection.each do |notification|
          bullet_warnings << notification.short_notice
        end
        Bullet.end_request
      end

      ActiveSupport::Notifications.unsubscribe(subscriber)

      # Determine duplicates
      real_duplicates = duplicate_queries.select { |_sql, count| count > 1 }

      is_warn = bullet_warnings.any? || real_duplicates.any? || queries.size > 15
      total_warnings += bullet_warnings.size + real_duplicates.size

      results << {
        role: role,
        label: label,
        path: path,
        status: status_code,
        queries_count: queries.size,
        duplicates_count: real_duplicates.values.sum,
        duration_ms: duration_ms,
        bullet_warnings: bullet_warnings,
        duplicate_queries: real_duplicates
      }
    end

    # Print Table Output
    puts sprintf("%-28s %-30s %-8s %-9s %-10s %-8s", "VISTA / ENDPOINT", "RUTA", "STATUS", "QUERIES", "DUPLICADOS", "TIEMPO")
    puts "-" * 98

    results.each do |res|
      status_icon = if res[:bullet_warnings].any?
                      "❌ N+1"
                    elsif res[:duplicates_count] > 0
                      "⚠️ DUP"
                    elsif res[:queries_count] > 12
                      "⚠️ HIGH"
                    else
                      "✅ OK"
                    end

      puts sprintf(
        "%-28s %-30s %-8s %-9s %-10s %-8s",
        res[:label][0..27],
        res[:path][0..29],
        res[:status],
        "#{res[:queries_count]} q",
        res[:duplicates_count] > 0 ? "#{res[:duplicates_count]} dup" : "0",
        "#{res[:duration_ms]}ms"
      )

      # Print detailed warnings if any
      if res[:bullet_warnings].any?
        res[:bullet_warnings].each do |warn|
          puts "   ↳ 🚨 Bullet Warning: #{warn}"
        end
      end

      if res[:duplicate_queries].any?
        res[:duplicate_queries].each do |sql, count|
          puts "   ↳ ⚠️ Query duplicada #{count}x: #{sql[0..80]}..."
        end
      end
    end

    puts "=" * 98
    puts "\n📊 RESUMEN DE AUDITORÍA:"
    puts "  • Total de endpoints auditados: #{results.size}"
    puts "  • Consultas promedio por vista: #{(results.sum { |r| r[:queries_count] }.to_f / results.size).round(1)}"
    puts "  • Alertas de N+1 detectadas: #{results.sum { |r| r[:bullet_warnings].size }}"
    puts "  • Consultas duplicadas detectadas: #{results.sum { |r| r[:duplicates_count] }}"
    
    if total_warnings == 0
      puts "\n✨ ¡EXCELENTE! Todas las consultas y vistas están 100% optimizadas sin N+1.\n"
    else
      puts "\n⚠️ Se encontraron #{total_warnings} puntos a revisar.\n"
    end
  end
end
