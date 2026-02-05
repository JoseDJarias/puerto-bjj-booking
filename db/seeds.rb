# db/seeds.rb

puts "🌱 Seeding database..."

# === TIPOS DE CLASE ===
puts "\n📚 Creating Class Types..."

jiujitsu = ClassType.find_or_create_by!(name: "Jiujitsu") do |ct|
  ct.description = "Brazilian Jiu-Jitsu training"
  ct.active = true
end

mma = ClassType.find_or_create_by!(name: "MMA") do |ct|
  ct.description = "Mixed Martial Arts training"
  ct.active = true
end

boxeo = ClassType.find_or_create_by!(name: "Boxeo") do |ct|
  ct.description = "Boxing training"
  ct.active = true
end

kids = ClassType.find_or_create_by!(name: "Kids") do |ct|
  ct.description = "Martial arts for kids"
  ct.active = true
end

puts "   ✓ Created #{ClassType.count} class types"

# === PLANES DE MEMBRESÍA ===
puts "\n💳 Creating Membership Plans..."

drop_in = MembershipPlan.find_or_create_by!(name: "Drop-in (Día)") do |plan|
  plan.duration_months = 0  # 0 = solo un día
  plan.price = 20.00
  plan.active = true
end

mensual = MembershipPlan.find_or_create_by!(name: "Mensual") do |plan|
  plan.duration_months = 1
  plan.price = 100.00
  plan.active = true
end

bimestre = MembershipPlan.find_or_create_by!(name: "Bimestre") do |plan|
  plan.duration_months = 2
  plan.price = 180.00
  plan.active = true
end

trimestre = MembershipPlan.find_or_create_by!(name: "Trimestre") do |plan|
  plan.duration_months = 3
  plan.price = 250.00
  plan.active = true
end

puts "   ✓ Created #{MembershipPlan.count} membership plans"

# === PAQUETES DE MEMBRESÍA ===
puts "\n📦 Creating Membership Packages..."

# Paquete: Jiujitsu + MMA
jj_package = MembershipPackage.find_or_create_by!(name: "Jiujitsu + MMA") do |pkg|
  pkg.description = "Acceso a clases de Jiujitsu y MMA"
  pkg.price_modifier = 0
  pkg.active = true
end
jj_package.class_types = [jiujitsu, mma] if jj_package.class_types.empty?

# Paquete: Boxeo + MMA
boxeo_package = MembershipPackage.find_or_create_by!(name: "Boxeo + MMA") do |pkg|
  pkg.description = "Acceso a clases de Boxeo y MMA"
  pkg.price_modifier = 0
  pkg.active = true
end
boxeo_package.class_types = [boxeo, mma] if boxeo_package.class_types.empty?

# Paquete: MMA Solo (NUEVO)
mma_package = MembershipPackage.find_or_create_by!(name: "MMA") do |pkg|
  pkg.description = "Acceso solo a clases de MMA"
  pkg.price_modifier = -20  # Más barato que los combos
  pkg.active = true
end
mma_package.class_types = [mma] if mma_package.class_types.empty?

# Paquete: Kids
kids_package = MembershipPackage.find_or_create_by!(name: "Kids") do |pkg|
  pkg.description = "Clases para niños"
  pkg.price_modifier = -20
  pkg.active = true
end
kids_package.class_types = [kids] if kids_package.class_types.empty?

# Paquete: Drop-in (para pago por día - todas las clases)
drop_in_package = MembershipPackage.find_or_create_by!(name: "Drop-in") do |pkg|
  pkg.description = "Acceso de un día a todas las clases"
  pkg.price_modifier = 0
  pkg.active = true
end
drop_in_package.class_types = [jiujitsu, mma, boxeo] if drop_in_package.class_types.empty?

puts "   ✓ Created #{MembershipPackage.count} membership packages"

# === USUARIOS DE PRUEBA ===
puts "\n👥 Creating Users..."

# Admin User
admin = User.find_or_create_by!(email_address: "admin@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
  user.status = :active
  user.first_name = "Admin"
  user.last_name = "Puerto BJJ"
  user.phone = "787-555-0001"
end
puts "   ✓ Admin: #{admin.email_address} (password: password123)"

# Instructor User
instructor = User.find_or_create_by!(email_address: "instructor@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :instructor
  user.status = :active
  user.first_name = "Carlos"
  user.last_name = "Instructor"
  user.phone = "787-555-0002"
end
puts "   ✓ Instructor: #{instructor.email_address} (password: password123)"

# Member User with Active Membership (Mensual)
member = User.find_or_create_by!(email_address: "member@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
  user.status = :active
  user.first_name = "Daniel"
  user.last_name = "Member"
  user.phone = "787-555-0003"
end

if member.memberships.empty?
  Membership.create!(
    user: member,
    membership_plan: mensual,
    membership_package: jj_package,
    start_date: Date.today,
    status: :active
  )
  puts "   ✓ Created membership for #{member.first_name} (Mensual - JJ+MMA)"
end

puts "   ✓ Member: #{member.email_address}"

# Drop-in User (pagó solo un día)
drop_in_user = User.find_or_create_by!(email_address: "dropin@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
  user.status = :active
  user.first_name = "Juan"
  user.last_name = "Drop-in"
  user.phone = "787-555-0004"
end

if drop_in_user.memberships.empty?
  Membership.create!(
    user: drop_in_user,
    membership_plan: drop_in,
    membership_package: drop_in_package,
    start_date: Date.today,
    status: :active,
    amount_paid: 20.00
  )
  puts "   ✓ Created drop-in membership for #{drop_in_user.first_name}"
end

puts "   ✓ Drop-in: #{drop_in_user.email_address}"

# Member with MULTIPLE disciplines (JJ + Boxeo) - segunda con 50% off
multi_discipline = User.find_or_create_by!(email_address: "multi@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
  user.status = :active
  user.first_name = "Maria"
  user.last_name = "Multi-Disciplina"
  user.phone = "787-555-0006"
end

if multi_discipline.memberships.empty?
  # Primera disciplina: JJ+MMA (precio completo)
  first_membership = Membership.create!(
    user: multi_discipline,
    membership_plan: mensual,
    membership_package: jj_package,
    start_date: Date.today,
    status: :active
  )
  puts "   ✓ Created 1st membership for #{multi_discipline.first_name}: #{first_membership.amount_paid}"
  
  # Segunda disciplina: Boxeo+MMA (50% off automático)
  second_membership = Membership.create!(
    user: multi_discipline,
    membership_plan: mensual,
    membership_package: boxeo_package,
    start_date: Date.today,
    status: :active
  )
  puts "   ✓ Created 2nd membership for #{multi_discipline.first_name}: #{second_membership.amount_paid} (50% off)"
end

puts "   ✓ Multi-discipline: #{multi_discipline.email_address}"

# Member without Membership
member_no_membership = User.find_or_create_by!(email_address: "nomembership@puertobjj.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
  user.status = :active
  user.first_name = "Pedro"
  user.last_name = "Sin Membresía"
  user.phone = "787-555-0005"
end
puts "   ✓ Member (no membership): #{member_no_membership.email_address}"

puts "\n✅ Seeding complete!"
puts "\n📊 Summary:"
puts "   - Class Types: #{ClassType.count}"
puts "   - Membership Plans: #{MembershipPlan.count} (incluye Drop-in)"
puts "   - Membership Packages: #{MembershipPackage.count}"
puts "   - Users: #{User.count}"
puts "   - Active Memberships: #{Membership.active.count}"
puts "\n💡 Login credentials (all): password123"
