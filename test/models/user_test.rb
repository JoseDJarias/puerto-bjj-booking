require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:admin) # Asumiendo que tienes fixtures
  end

  # --- Tests de Nombre y Apellido ---
 
  test "no debe ser válido sin nombre" do
    user = User.new(last_name: "Test", identification: "112340567", email_address: "no.nombre@test.com", password: "password123")
    user.valid?
    
    assert_includes user.errors.full_messages, "Nombre no puede estar en blanco"
  end
  
  test "no debe ser válido sin apellido" do
    user = User.new(first_name: "Daniel", identification: "112340567", email_address: "no.apellido@test.com", password: "password123")
    user.valid?
    
    assert_includes user.errors.full_messages, "Apellido no puede estar en blanco"
  end
  # --- Tests de Identificación ---

  test "debe normalizar la identificación (quitar guiones y subir a mayúsculas)" do
    user = User.new(first_name: "Daniel", last_name: "Test", identification: "1-1234-0567", email_address: "norm@test.com", password: "password123")
    user.validate
    assert_equal "112340567", user.identification
  end

  test "debe ser válido con cédula de Costa Rica (exactamente 9 dígitos)" do
    user = User.new(first_name: "Daniel", last_name: "Test", identification: "112340567", email_address: "tico@test.com", password: "password123")
    assert user.valid?, "Debería ser válida una cédula de 9 dígitos"
  end

  test "debe fallar si son solo números pero no son 9 dígitos" do
    user = User.new(identification: "12345678") # 8 dígitos
    assert_not user.valid?
    assert_includes user.errors[:identification], "debe tener exactamente 9 dígitos (Cédula CR). Si es un pasaporte numérico, verifíquelo con el Admin."
  end

  test "debe ser válido con pasaporte alfanumérico (letras y números)" do
    user = User.new(first_name: "Daniel", last_name: "Test", identification: "CAN123456", email_address: "can@test.com", password: "password123")
    assert user.valid?
  end

  test "debe fallar si el pasaporte es demasiado corto o largo" do
    user_corto = User.new(identification: "ABC12") # 5 chars
    user_largo = User.new(identification: "A" * 16) # 16 chars
    assert_not user_corto.valid?
    assert_not user_largo.valid?
  end

  # --- Test del Superpoder del Admin (Conditional Uniqueness) ---

  test "el admin debe poder guardar una identificación duplicada usando admin_editing" do
    existing_user = users(:admin) # Ya tiene una identificación en fixtures
    new_user = User.new(
      first_name: "Duplicado", 
      last_name: "Test", 
      email_address: "duplicado@test.com", 
      password: "password123",
      identification: existing_user.identification
    )

    # Primero fallamos: Sin el permiso de admin no debe ser válido
    assert_not new_user.valid?, "No debería permitir duplicado por defecto"

    # Segundo éxito: Con el permiso de admin sí debe ser válido
    new_user.admin_editing_password = true
    assert new_user.valid?, "El admin debería poder saltarse la unicidad"
  end

  test "el admin puede dejar la identificación en blanco si es necesario" do
    user = User.new(first_name: "Sin", last_name: "ID", email_address: "no-id@test.com", password: "password123")
    
    assert_not user.valid?, "Usuario normal no puede estar sin ID"
    
    user.admin_editing_password = true
    assert user.valid?, "Admin debería poder guardar sin ID"
  end

  # --- Tests de Contraseña ---

  test "debe requerir contraseña de mínimo 8 caracteres al crear" do
    user = User.new(first_name: "Daniel", last_name: "Test" ,password: "1234567")
    assert_not user.valid?
    assert_includes user.errors[:password], "es demasiado corto (mínimo 8 caracteres)"
  end

  test "debe permitir actualizar otros campos sin enviar la contraseña" do
    user = users(:admin)
    user.nickname = "Nuevo Apodo"
    
    assert user.save, "Debería guardar cambios de perfil sin pedir la contraseña"
    assert_equal "Nuevo Apodo", user.reload.nickname
  end

  test "debe validar la longitud si se intenta cambiar la contraseña" do
    user = users(:admin)
    user.first_name = "Daniel"
    user.last_name = "Test"
    user.password = "123"
    
    assert_not user.save, "No debería permitir cambiar a una contraseña corta"
  end


  # --- Tests de Estadísticas del Dashboard ---

  test "self.stats debe calcular correctamente los estados basados en approved_at y status" do
    # En lugar de delete_all, creamos usuarios con emails únicos para este test
    # Aprobado y Activo
    User.create!(
      first_name: "Ok", last_name: "1", identification: "111110111", 
      email_address: "aprobado@test.com", password: "password123", 
      approved_at: Time.current, status: :active
    )

    # Pendiente (approved_at nil)
    User.create!(
      first_name: "Pending", last_name: "User", identification: "222220222", 
      email_address: "pendiente@test.com", password: "password123", 
      approved_at: nil, status: :active
    )

    # Inactivo (status: 1)
    User.create!(
      first_name: "Inactive", last_name: "User", identification: "333330333", 
      email_address: "inactivo@test.com", password: "password123", 
      approved_at: Time.current, status: :inactive
    )

    # Suspendido (status: 2)
    User.create!(
      first_name: "Suspended", last_name: "User", identification: "444440444", 
      email_address: "suspendido@test.com", password: "password123", 
      approved_at: Time.current, status: :suspended
    )

    # Ejecutamos el método sobre todos los usuarios (incluyendo los de tus fixtures)
    stats = User.stats
    
    # Assertions lógicas:
    # 1. El total debe ser al menos 4 (los que creamos) + los que tengas en fixtures
    assert stats.total >= 4
    
    # 2. Verificamos que los inactivos y suspendidos se sumen (1 de cada uno = 2)
    # Si tus fixtures tienen más inactivos, ajusta el número o usa un scope
    inactivos_esperados = User.where(status: [:inactive, :suspended]).count
    assert_equal inactivos_esperados, stats.inactive, "Debe sumar inactivos y suspendidos"

    # 3. Verificamos la lógica de pendientes
    pendientes_esperados = User.where(approved_at: nil).count
    assert_equal pendientes_esperados, stats.pending, "Debe contar usuarios con approved_at nil"
  end
end