# test/jobs/expire_memberships_job_test.rb
require "test_helper"

class ExpireMembershipsJobTest < ActiveJob::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    # Asumimos que tienes fixtures o puedes crear los registros aquí.
    # Configuramos la zona horaria de la academia para la prueba.
    Time.zone = "America/Costa_Rica"
    
    @user = users(:one) 
    @package = membership_packages(:unlimited) 
    @plan = membership_plans(:monthly)
  end

  test "debe expirar membresías vencidas y mantener activas las que aún tienen vigencia" do
    # ESCENARIO: Fijamos el tiempo "hoy" en Costa Rica como 4 de Junio a las 10:00 AM
    hoy_local = Time.zone.parse("2026-06-04 10:00:00")

    travel_to hoy_local do
      # 1. Membresía que YA venció (Vencía ayer 3 de Junio) -> DEBE EXPIRAR
      @membresia_vencida = Membership.create!(
        user: @user,
        membership_package: @package,
        membership_plan: @plan,
        start_date: Date.parse("2026-05-03"),
        end_date: Date.parse("2026-06-03"),
        status: :active
      )

      # 2. Membresía que vence en el futuro (Vence el 13 de Junio, como la de Leo) -> DEBE SEGUIR ACTIVA
      @membresia_valida = Membership.create!(
        user: @user,
        membership_package: @package,
        membership_plan: @plan,
        start_date: Date.parse("2026-05-13"),
        end_date: Date.parse("2026-06-13"),
        status: :active
      )
    end

    # SIMULACIÓN DEL BUG: Viajamos en el tiempo a la noche de Costa Rica (10:00 PM del 4 de Junio).
    # En el servidor UTC ya es la madrugada del 5 de Junio (Date.current se desfasa).
    noche_con_desfase_utc = Time.zone.parse("2026-06-04 22:00:00")

    travel_to noche_con_desfase_utc do
      # Ejecutamos el Job de forma síncrona
      ExpireMembershipsJob.perform_now

      # === VERIFICACIONES (Asserts) ===
      
      # La membresía que venció el 3 de junio debe pasar a 'expired'
      assert_equal "expired", @membresia_vencida.reload.status, "La membresía vieja debió expirar"

      # La membresía de Leo (vence el 13) debe SEGUIR activa. 
      # Si el Job usara Date.current (del servidor UTC), este assert fallaría y capturarías el bug.
      assert_equal "active", @membresia_valida.reload.status, "La membresía de Leo NO debió expirar porque vence en el futuro"
    end
  end

  test "el propio día del vencimiento la membresía debe permanecer activa" do
    Time.use_zone("America/Costa_Rica") do
      # Creamos una membresía que vence hoy mismo 4 de Junio
      membresia_vence_hoy = Membership.create!(
        user: @user,
        membership_package: @package,
        membership_plan: @plan,
        start_date: Date.parse("2026-05-04"),
        end_date: Date.parse("2026-06-04"),
        status: :active
      )

      # Viajamos a las 4:00 PM del propio día de su vencimiento
      travel_to Time.zone.parse("2026-06-04 16:00:00") do
        ExpireMembershipsJob.perform_now
        
        # El alumno tiene derecho a entrenar todo el día de su vencimiento
        assert_equal "active", membresia_vence_hoy.reload.status, "La membresía debe seguir activa durante su último día"
      end
    end
  end
end