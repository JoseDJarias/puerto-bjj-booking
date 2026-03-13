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

# 6. Usuarios corregidos con identificación
puts "👥 Creating Users (Admin, Instructor, Member)..."

# ADMIN
User.find_or_create_by!(email_address: "admin@puertobjj.com") do |u|
  u.password = "password123"
  u.role = :admin
  u.first_name = "Daniel"
  u.last_name = "Admin"
  u.identification = "1-1111-1111" # Agregado
  u.phone_number = "88880001"
  u.approved_at = Time.current
end

# INSTRUCTOR
User.find_or_create_by!(email_address: "instructor@puertobjj.com") do |u|
  u.password = "password123"
  u.role = :instructor
  u.first_name = "Carlos"
  u.last_name = "Gracie"
  u.identification = "2-2222-2222" # Agregado
  u.phone_number = "88880002"
  u.approved_at = Time.current
end

# MEMBER
User.find_or_create_by!(email_address: "member@puertobjj.com") do |u|
  u.password = "password123"
  u.role = :member
  u.first_name = "Daniel"
  u.last_name = "Arias"
  u.identification = "3-3333-3233" # Agregado
  u.phone_number = "88880003"
  u.approved_at = Time.current
end
3.times { member.drop_in_tickets.create!(price_paid: 5000) }

puts "   ✓ Users created with identification"

# OTRO MIEMBRO (Ana solo con membresía específica)
member_ana = User.find_or_create_by!(email_address: "ana@puertobjj.com") do |u|
  u.password = "password123"
  u.role = :member
  u.first_name = "Ana"
  u.last_name = "Rodriguez"
  u.identification = "3-3333-3333" # Agregado
  u.phone_number = "88880004"
  u.approved_at = Time.current
end
Membership.create!(user: member_ana, membership_plan: mensual, membership_package: jj_pkg, start_date: Date.current)

puts "   ✓ Users and memberships created"

# 7. Horarios de Clase
puts "📅 Creating Class Schedules..."
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