require "test_helper"

class ClassScheduleTest < ActiveSupport::TestCase

  test "validación de modalidades y visibilidad de badges" do
    # 1. Recuperamos las clases desde tus fixtures
    bjj_gi_1    = class_schedules(:one)   # BJJ Gi
    bjj_gi_2    = class_schedules(:two)   # BJJ Gi
    bjj_nogi    = class_schedules(:three) # BJJ No-Gi
    boxeo_class = class_schedules(:four)  # Boxeo (sin modalidad)

    # --- CASOS BJJ GI (one & two) ---
    assert bjj_gi_1.gi?, "La clase 'one' debería ser GI"
    assert bjj_gi_2.gi?, "La clase 'two' debería ser GI"
    assert bjj_gi_1.show_modality?, "BJJ Gi debe mostrar el badge"
    assert_equal "gi", bjj_gi_1.modality

    # --- CASO BJJ NO-GI (three) ---
    assert bjj_nogi.nogi?, "La clase 'three' debería ser NO-GI"
    assert bjj_nogi.show_modality?, "BJJ No-Gi debe mostrar el badge"
    assert_equal "nogi", bjj_nogi.modality

    # --- CASO BOXEO (four) ---
    assert_nil boxeo_class.modality, "Boxeo no debe tener modalidad (nil)"
    assert_not boxeo_class.show_modality?, "Boxeo NO debe mostrar badge"
  end

  test "el enum mapea correctamente a los integers de la base de datos" do
    # Cargamos de nuevo para estar seguros
    gi_class = class_schedules(:one)
    
    # Opción A: Verificar el valor antes de la conversión de Rails
    assert_equal 0, gi_class.read_attribute_before_type_cast(:modality), "En la DB el valor de Gi debe ser 0"
    
    # Opción B: Verificar el No-Gi (debería ser 1)
    nogi_class = class_schedules(:three)
    assert_equal 1, nogi_class.read_attribute_before_type_cast(:modality), "En la DB el valor de No-Gi debe ser 1"
  end

  # --- dashboard_upcoming + grace period ---
  test "dashboard_upcoming incluye clase que aún no ha empezado" do
    base = Time.zone.now
    schedule = ClassSchedule.create!(
      starts_at: base + 1.hour,
      duration_minutes: 60,
      capacity: 20,
      instructor: users(:admin),
      class_type: class_types(:bjj_gi),
      cancelled: false
    )
    travel_to base do
      assert_includes ClassSchedule.dashboard_upcoming, schedule,
        "Una clase que empieza en el futuro debe aparecer en dashboard_upcoming"
    end
  end

  test "dashboard_upcoming incluye clase que ya empezó pero está dentro del grace period" do
    starts_at = Time.zone.now - 5.minutes
    schedule = ClassSchedule.create!(
      starts_at: starts_at,
      duration_minutes: 60,
      capacity: 20,
      instructor: users(:admin),
      class_type: class_types(:bjj_gi),
      cancelled: false
    )
    # "Ahora" = 5 min después del inicio → todavía en grace de 20 min
    travel_to starts_at + 5.minutes do
      assert_includes ClassSchedule.dashboard_upcoming, schedule,
        "Una clase que empezó hace 5 min debe seguir visible durante el grace period (20 min)"
    end
  end

  test "dashboard_upcoming excluye clase que empezó hace más del grace period" do
    starts_at = Time.zone.now - 25.minutes
    schedule = ClassSchedule.create!(
      starts_at: starts_at,
      duration_minutes: 60,
      capacity: 20,
      instructor: users(:admin),
      class_type: class_types(:bjj_gi),
      cancelled: false
    )
    travel_to starts_at + 25.minutes do
      assert_not_includes ClassSchedule.dashboard_upcoming, schedule,
        "Una clase que empezó hace más de 20 min no debe aparecer en dashboard_upcoming"
    end
  end

  test "dashboard_upcoming ordena por starts_at ascendente" do
    base = Time.zone.now
    c1 = ClassSchedule.create!(starts_at: base + 2.hours, duration_minutes: 60, capacity: 20, instructor: users(:admin), class_type: class_types(:bjj_gi), cancelled: false)
    c2 = ClassSchedule.create!(starts_at: base + 1.hour, duration_minutes: 60, capacity: 20, instructor: users(:admin), class_type: class_types(:bjj_gi), cancelled: false)
    travel_to base do
      ids = ClassSchedule.dashboard_upcoming.pluck(:id)
      assert ids.index(c2.id) < ids.index(c1.id), "La clase más temprana (c2) debe aparecer antes que c1"
    end
  end
end