require "test_helper"

class AccountLocksResourceTest < Minitest::Test
  def test_retrieve_returns_the_locks_and_lock_date_range
    stub_api(:get, "account_locks", fixture: "account_locks/list_account_locks_for_a_company")

    locks = client.account_locks.retrieve

    assert_equal 2, locks.account_locks.count
    assert_equal FreeAgent::AccountLock, locks.account_locks.first.class
    assert_equal "2024-03-31", locks.account_locks.first.locked_to_date
    assert_equal true, locks.account_locks.first.user_lock
    assert_equal "2024-01-01", locks.earliest_lock_date
    assert_equal "2024-12-31", locks.latest_lock_date
  end

  def test_update_sets_the_user_lock
    stub_api(:put, "account_locks", request_body: { account_lock: { locked_to_date: "2024-01-01" } }, status: 204)

    assert_equal true, client.account_locks.update(locked_to_date: "2024-01-01")
  end

  def test_delete_removes_the_user_lock
    stub_api(:delete, "account_locks", status: 204)

    assert_equal true, client.account_locks.delete
  end
end
