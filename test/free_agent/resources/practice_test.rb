require "test_helper"

class PracticeResourceTest < Minitest::Test
  # The docs example has no status line, so the fixture script doesn't pick it up
  def test_practice_retrieve
    stub_api(:get, "practice", body: { name: "My Practice", subdomain: "mypracticesubdomain" })

    practice = client.practice.retrieve

    assert_equal FreeAgent::Practice, practice.class
    assert_equal "My Practice", practice.name
    assert_equal "mypracticesubdomain", practice.subdomain
  end

  def test_clients_list
    stub_api(:get, "clients", query: { view: "active", sort: "-created_at" }, fixture: "accountancy_practice_api/list_clients")

    clients = client.clients.list(view: "active", sort: "-created_at")

    assert_equal FreeAgent::Collection, clients.class
    assert_equal FreeAgent::PracticeClient, clients.first.class
    assert_equal "Test Company", clients.first.name
    assert_equal "testcompany", clients.first.subdomain
    assert_equal "Jane", clients.first.account_owner.first_name
  end

  def test_clients_list_minimal
    stub_api(:get, "clients", query: { minimal_data: "true", per_page: "500" }, fixture: "accountancy_practice_api/list_clients_2")

    clients = client.clients.list(minimal_data: true, per_page: 500)

    assert_equal 123, clients.first.id
    assert_equal "testcompany", clients.first.subdomain
  end

  def test_account_managers_list
    stub_api(:get, "account_managers", fixture: "accountancy_practice_api/list_account_managers")

    managers = client.account_managers.list

    assert_equal FreeAgent::AccountManager, managers.first.class
    assert_equal "Bobson Dugnutt", managers.first.name
  end

  def test_account_managers_retrieve
    stub_api(:get, "account_managers/123", fixture: "accountancy_practice_api/get_details_of_a_single_account_manager")

    manager = client.account_managers.retrieve(id: 123)

    assert_equal "bobson@some-accounting-firm.com", manager.email
    assert_equal "123", manager.id
  end

  def test_account_managers_me
    stub_api(:get, "account_managers/me", fixture: "accountancy_practice_api/get_details_of_the_current_account_manager")

    assert_equal "Bobson Dugnutt", client.account_managers.me.name
  end

  def test_requests_on_behalf_of_a_client_send_the_subdomain
    stub_api(:get, "contacts", headers: { "X-Subdomain" => "testcompany" }, fixture: "contacts/list_all_contacts")

    assert_equal 1, client.on_behalf_of("testcompany").contacts.list.count
  end
end
