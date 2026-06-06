require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:one) 
    @package = membership_packages(:unlimited) 
    @plan = membership_plans(:monthly) 
  end

  # --- TESTS DE PRECIOS ---

  test "debe calcular el precio automático basado en el pricing de la fixture" do
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: Time.zone.today
    )
    assert membership.valid?
    assert_equal 100.0, membership.amount_paid.to_f
  end

  test "debe respetar el monto manual de 0 (caso Juan el pintor)" do
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: Time.zone.today,
      amount_paid: 0
    )
    assert membership.valid?
    assert_equal 0, membership.amount_paid
  end

  test "debe cargar el precio del paquete combo desde la tabla de pricing" do
    # Creamos el paquete especial
    combo_pkg = MembershipPackage.create!(name: "Jiu Jitsu + Boxeo", active: true)
    
    # Le asignamos un precio fijo en la matriz (ej: 45,000)
    MembershipPricing.create!(
      membership_package: combo_pkg, 
      membership_plan: @plan, 
      price: 45000
    )
    
    membership = Membership.new(
      user: @user, 
      membership_package: combo_pkg, 
      membership_plan: @plan, 
      start_date: Time.zone.today
    )
    
    membership.valid?
    
    assert_equal 45000.0, membership.amount_paid.to_f, "Debe traer el precio definido para el combo"
  end

  # --- TESTS DE FECHAS ---

  test "debe calcular la fecha de vencimiento automática (1 mes)" do
    hoy = Time.zone.today
    membership = Membership.create!(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: hoy
    )
    assert_equal hoy + 1.month, membership.end_date
  end

  test "debe respetar la fecha de vencimiento puesta manualmente por el admin" do
    hoy = Time.zone.today
    fecha_forzada = hoy + 15.days # Solo le damos 15 días por alguna razón
    
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: hoy,
      end_date: fecha_forzada
    )
    
    assert membership.valid?
    assert_equal fecha_forzada, membership.end_date, "El sistema no debe sobreescribir la fecha si el admin la puso"
  end

  test "debe calcular el fin correctamente si la fecha de inicio es en el pasado" do
    hace_un_mes = Time.zone.today - 1.month
    membership = Membership.create!(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: hace_un_mes
    )
    # Si empezó hace un mes y el plan es mensual, vence HOY
    assert_equal hace_un_mes + 1.month, membership.end_date
  end

  test "debe calcular el fin de mes exacto (15 de mayo al 15 de junio) respetando la zona horaria" do
    # Simulamos que la app está configurada para Costa Rica
    Time.use_zone("America/Costa_Rica") do
      # Forzamos una fecha fija para el inicio del test
      start_date_cr = Date.parse("2026-05-15")
      
      membership = Membership.create!(
        user: @user,
        membership_package: @package,
        membership_plan: @plan, # Asumiendo duración de 1 mes
        start_date: start_date_cr
      )
      
      # Verificamos que la fecha de vencimiento sea exactamente el mismo día del mes siguiente
      assert_equal Date.parse("2026-06-15"), membership.end_date, "Si pagó el 15, debe vencer el 15 del mes siguiente"
    end
  end
end
