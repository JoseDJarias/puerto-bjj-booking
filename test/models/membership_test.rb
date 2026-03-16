require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @user = users(:one) # Juan Perez
    @package = membership_packages(:unlimited) # Plan Ilimitado
    @plan = membership_plans(:monthly) # Mensual
    
    # El pricing ya viene de fixtures/membership_pricings.yml (:one)
    # que une unlimited + monthly con un precio de 100.0
  end

  test "debe calcular el precio automático basado en el pricing de la fixture" do
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: Date.current
    )
    
    assert membership.valid?, "La membresía debería ser válida"
    assert_equal 100.0, membership.amount_paid.to_f, "Debería haber tomado los 100.0 del pricing 'one'"
  end

  test "debe respetar el monto manual de 0 (caso Juan el pintor)" do
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: Date.current,
      amount_paid: 0
    )
    
    assert membership.valid?
    # Aquí es donde validamos que el modelo NO sobreescriba el 0 con el 100 del pricing
    assert_equal 0, membership.amount_paid, "El sistema debería respetar el precio manual de 0"
  end

  test "debe respetar un precio especial mayor a 0 puesto por el admin" do
    membership = Membership.new(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: Date.current,
      amount_paid: 75.0 # Un descuento especial
    )
    
    assert membership.valid?
    assert_equal 75.0, membership.amount_paid, "El sistema debería respetar el precio manual de 75.0"
  end

  test "debe calcular la fecha de vencimiento sumando meses del plan" do
    hoy = Date.current
    membership = Membership.create!(
      user: @user,
      membership_package: @package,
      membership_plan: @plan,
      start_date: hoy
    )
    
    # Como el plan 'monthly' es de 1 mes:
    assert_equal hoy + 1.month, membership.end_date
  end
end