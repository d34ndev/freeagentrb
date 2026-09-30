require "test_helper"

class PayrollProfilesResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "payroll_profiles/2026", fixture: "payroll_profiles/list_all_profiles_for_a_given_tax_year")

    profile = client.payroll_profiles.list(year: 2026).first

    assert_equal FreeAgent::PayrollProfile, profile.class
    assert_equal "EMP001", profile.payroll_reference
    assert_equal 1000.0, profile.total_pay_in_previous_employment
  end

  def test_list_for_a_user
    user = "https://api.freeagent.com/v2/users/107"
    stub_api(:get, "payroll_profiles/2026", query: { user: user }, fixture: "payroll_profiles/payroll_profile_for_a_particular_user")

    assert_equal 1, client.payroll_profiles.list(year: 2026, user: user).count
  end
end
