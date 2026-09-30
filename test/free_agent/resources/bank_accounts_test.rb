require "test_helper"

class BankAccountsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "bank_accounts", fixture: "bank_accounts/list_bank_accounts")

    bank_accounts = client.bank_accounts.list

    assert_equal FreeAgent::Collection, bank_accounts.class
    assert_equal FreeAgent::BankAccount, bank_accounts.first.class
    assert_equal "Default bank account", bank_accounts.first.name
    assert_equal "1", bank_accounts.first.id
  end

  def test_list_with_view
    stub_api(:get, "bank_accounts", query: { view: "standard_bank_accounts" }, fixture: "bank_accounts/list_bank_accounts")

    assert_equal 1, client.bank_accounts.list(view: "standard_bank_accounts").count
  end

  def test_retrieve
    stub_api(:get, "bank_accounts/1", fixture: "bank_accounts/get_a_single_bank_account")

    bank_account = client.bank_accounts.retrieve(id: 1)

    assert_equal FreeAgent::BankAccount, bank_account.class
    assert_equal "GBP", bank_account.currency
  end

  def test_create_wraps_the_payload
    stub_api(:post, "bank_accounts",
      request_body: { bank_account: { type: "StandardBankAccount", name: "Default bank account", opening_balance: "0.0" } },
      status: 201, fixture: "bank_accounts/create_a_bank_account")

    bank_account = client.bank_accounts.create(name: "Default bank account", opening_balance: "0.0")

    assert_equal FreeAgent::BankAccount, bank_account.class
    assert_equal "Default bank account", bank_account.name
  end

  def test_update_wraps_the_payload
    stub_api(:put, "bank_accounts/1", request_body: { bank_account: { name: "Renamed" } }, fixture: "bank_accounts/get_a_single_bank_account")

    assert_equal FreeAgent::BankAccount, client.bank_accounts.update(id: 1, name: "Renamed").class
  end

  def test_delete
    stub_api(:delete, "bank_accounts/1")

    assert_equal true, client.bank_accounts.delete(id: 1)
  end
end
