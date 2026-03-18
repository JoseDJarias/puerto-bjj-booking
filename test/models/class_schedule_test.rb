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
end