# test/models/concerns/membership_validator_test.rb
require "test_helper"

class MembershipValidatorTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    Time.zone = "America/Costa_Rica"

    # Using fixtures directly prevents database constraint conflicts
    @user = users(:one)
    @package = membership_packages(:bjj_plus_mma)
    @plan = membership_plans(:monthly)
    @class_type_bjj = class_types(:bjj_gi)
  end

  # --- SCENARIO 1: MEMBERSHIP ACCESS ---

  test "has_booking_access? should be true if an active membership covers today" do
    travel_to Time.zone.parse("2026-06-06 10:00:00") do
      @user.memberships.create!(
        membership_package: @package,
        membership_plan: @plan,
        start_date: Time.zone.today,
        end_date: Time.zone.today + 1.month,
        status: :active
      )

      assert @user.has_booking_access?
      assert @user.authorized_for?(@class_type_bjj)
    end
  end

  test "has_booking_access? should be false if membership expired yesterday" do
    travel_to Time.zone.parse("2026-06-06 10:00:00") do
      @user.memberships.create!(
        membership_package: @package,
        membership_plan: @plan,
        start_date: Time.zone.today - 1.month,
        end_date: Time.zone.today - 1.day,
        status: :expired
      )

      refute @user.has_booking_access?
    end
  end

  # --- SCENARIO 2: DROP-IN TICKET ACCESS ---

  test "has_booking_access? should be true if user has unused drop-in tickets" do
    travel_to Time.zone.parse("2026-06-06 10:00:00") do
      @user.drop_in_tickets.create!(status: :unused)

      assert @user.has_booking_access?
      assert @user.unused_tickets?
      assert_equal 1, @user.unused_tickets_count
    end
  end

  test "drop_in_active_today? should be true only if ticket was used today in local time zone" do
    travel_to Time.zone.parse("2026-06-06 08:00:00") do
      @user.drop_in_tickets.create!(status: :used, used_at: Time.zone.now)
    end

    travel_to Time.zone.parse("2026-06-06 23:30:00") do
      assert @user.drop_in_active_today?
    end

    travel_to Time.zone.parse("2026-06-07 06:00:00") do
      refute @user.drop_in_active_today?
    end
  end

  # --- SCENARIO 3: EDGE CASES ---

  test "admin always has booking access regardless of memberships" do
    @admin = users(:admin)

    assert @admin.has_booking_access?
    assert @admin.authorized_for?(@class_type_bjj)
  end

  test "non-eligible user never has booking access" do
    @user.update!(approved_at: nil)
    @user.drop_in_tickets.create!(status: :unused)

    refute @user.has_booking_access?
  end
end
