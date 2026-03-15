require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:admin) # Asumiendo que tienes fixtures
  end

  # --- Tests de Identificación ---

  test "debe normalizar la identificación (quitar guiones y subir a mayúsculas)" do
    user = User.new(identification: "1-1234-5678", email_address: "nuevo@test.com", password: "password123")
    user.validate
    assert_equal "112345678", user.identification
  end

  test "debe ser válido con cédula de Costa Rica (9 dígitos)" do
    user = User.new(identification: "112340567", email_address: "tico@test.com", password: "password123")
    assert user.valid?, "Debería ser válida una cédula de 9 dígitos"
  end

  test "debe ser válido con pasaporte extranjero (alfanumérico)" do
    user = User.new(identification: "PAS123456", email_address: "ext@test.com", password: "password123")
    assert user.valid?, "Debería ser válido un pasaporte alfanumérico"
  end

  test "debe fallar si la identificación no cumple ningún formato" do
    user = User.new(identification: "123") # Muy corto
    assert_not user.valid?
    assert_includes user.errors[:identification], "debe ser una cédula de 9 dígitos o un pasaporte válido (6-15 caracteres)"
  end

  # --- Tests de Contraseña ---

  test "debe requerir contraseña de mínimo 8 caracteres al crear" do
    user = User.new(password: "1234567")
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
    user.password = "123"
    
    assert_not user.save, "No debería permitir cambiar a una contraseña corta"
  end
end