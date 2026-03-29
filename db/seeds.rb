# db/seeds.rb
puts "🌱 Seeding Puerto BJJ (Rails 8)..."

# 1. Limpieza total desactivando restricciones de integridad (SQLite)
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF;")

tables_to_clean = [
  Booking, 
  DropInTicket, 
  Membership, 
  MembershipPricing, 
  MembershipPackageClassType,
  ClassSchedule,
  MembershipPlan, 
  MembershipPackage, 
  ClassType, 
  User,
  Session
]

tables_to_clean.each do |model|
  model.destroy_all
  # Reseteamos los IDs para que empiecen en 1
  ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='#{model.table_name}'")
rescue => e
  puts "   ⚠️  Could not clean #{model}: #{e.message}"
end

ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON;")
puts "   ✓ Database cleaned"

# 2. Tipos de Clase
puts "📚 Creating Class Types..."
jiujitsu = ClassType.create!(name: "Jiujitsu", description: "BJJ training", active: true)
mma      = ClassType.create!(name: "MMA", description: "Mixed Martial Arts", active: true)
boxeo    = ClassType.create!(name: "Boxeo", description: "Boxing training", active: true)
kids     = ClassType.create!(name: "Kids", description: "Kids martial arts", active: true)
puts "   ✓ Created 4 class types"

# 3. Planes (Solo Recurrentes)
puts "💳 Creating Membership Plans..."
mensual   = MembershipPlan.create!(name: "Mensual", duration_months: 1, price: 100, active: true)
bimestre  = MembershipPlan.create!(name: "Bimestre", duration_months: 2, price: 180, active: true)
trimestre = MembershipPlan.create!(name: "Trimestre", duration_months: 3, price: 250, active: true)
puts "   ✓ Created 3 plans"

# 4. Paquetes
puts "📦 Creating Membership Packages..."
jj_pkg = MembershipPackage.create!(name: "Jiujitsu + MMA", active: true)
jj_pkg.class_types = [jiujitsu, mma]

box_pkg = MembershipPackage.create!(name: "Boxeo + MMA", active: true)
box_pkg.class_types = [boxeo, mma]

kids_pkg = MembershipPackage.create!(name: "Kids", active: true)
kids_pkg.class_types = [kids]
puts "   ✓ Created 3 packages"

# 5. Precios (Matriz de precios en Colones)
[jj_pkg, box_pkg, kids_pkg].each do |pkg|
  price_base = pkg == jj_pkg ? 25000 : (pkg == box_pkg ? 20000 : 15000)
  MembershipPricing.create!(membership_package: pkg, membership_plan: mensual, price: price_base)
  MembershipPricing.create!(membership_package: pkg, membership_plan: bimestre, price: price_base * 1.8)
  MembershipPricing.create!(membership_package: pkg, membership_plan: trimestre, price: price_base * 2.5)
end

puts "👥 Creating Users..."

# 6. Usuarios (Usando una forma más robusta)
users_data = [
  { email_address: "admin@puertobjj.com", password: "password123", role: "admin", first_name: "Daniel", last_name: "Admin", identification: "123457895", phone_number: "88880001" },
  { email_address: "instructor@puertobjj.com", password: "password123", role: "instructor", first_name: "Carlos", last_name: "Gracie", identification: "123457896", phone_number: "88880002" },
  { email_address: "member@puertobjj.com", password: "password123", role: "member", first_name: "Daniel", last_name: "Arias", identification: "123457892", phone_number: "88880003" }
]

users_data.each do |data|
  user = User.find_or_initialize_by(email_address: data[:email_address])
  user.assign_attributes(data)
  user.approved_at = Time.current
  
  if user.save
    puts "   ✓ User #{data[:email_address]} created/updated"
  else
    puts "   ❌ Error creating #{data[:email_address]}: #{user.errors.full_messages.join(', ')}"
    # Esto evitará que el bin/rails aborted! nos oculte el error
  end
end

puts "   ✓ Users created with identification"


# 7. Horarios de Clase
puts "📅 Creating Class Schedules..."
instructor = User.find_by!(email_address: "instructor@puertobjj.com")
base = 1.day.from_now.beginning_of_day
[
  [jiujitsu, base + 9.hours],
  [mma, base + 11.hours],
  [jiujitsu, base + 1.day + 18.hours],
  [boxeo, base + 15.hours],
  [kids, base + 2.days + 10.hours]
].each do |ct, starts|
  ClassSchedule.create!(
    class_type: ct,
    instructor: instructor,
    starts_at: starts,
    duration_minutes: 60,
    capacity: 20,
    cancelled: false
  )
end

puts "✅ SEED COMPLETED SUCCESSFULLY!"
puts "-------------------------------------------------------"
puts "Admin: admin@puertobjj.com / password123"
puts "Instructor: instructor@puertobjj.com / password123"
puts "Member (Tickets): member@puertobjj.com / password123"
puts "Member (Monthly): ana@puertobjj.com / password123"
puts "-------------------------------------------------------"