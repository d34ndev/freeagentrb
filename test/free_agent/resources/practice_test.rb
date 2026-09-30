require "test_helper"

class PracticeResourceTest < Minitest::Test
  def test_practice_retrieve
    setup_client
    practice = @client.practice.retrieve

    assert_equal FreeAgent::Practice, practice.class
    assert_equal "My Practice", practice.name
    assert_equal "mypracticesubdomain", practice.subdomain
  end

  def test_clients_list
    setup_client
    clients = @client.clients.list

    assert_equal FreeAgent::Collection, clients.class
    assert_equal FreeAgent::PracticeClient, clients.first.class
    assert_equal "Test Company", clients.first.name
    assert_equal "testcompany", clients.first.subdomain
    assert_equal "Jane", clients.first.account_owner.first_name
  end

  def test_clients_list_minimal
    setup_client
    clients = @client.clients.list(minimal_data: true, per_page: 500)

    assert_equal 2, clients.count
    assert_equal 123, clients.first.id
    assert_equal "anothercompany", clients.last.subdomain
  end

  def test_account_managers_list
    setup_client
    managers = @client.account_managers.list

    assert_equal FreeAgent::Collection, managers.class
    assert_equal FreeAgent::AccountManager, managers.first.class
    assert_equal "Bobson Dugnutt", managers.first.name
  end

  def test_account_managers_retrieve
    setup_client
    manager = @client.account_managers.retrieve(id: 123)

    assert_equal FreeAgent::AccountManager, manager.class
    assert_equal "bobson@some-accounting-firm.com", manager.email
    assert_equal "123", manager.id
  end

  def test_account_managers_me
    client = stub_client do |stubs|
      stubs.get("/v2/account_managers/me") do
        json({ "account_manager" => { "url" => "https://api.freeagent.com/v2/account_managers/123", "name" => "Jane" } })
      end
    end

    manager = client.account_managers.me

    assert_equal FreeAgent::AccountManager, manager.class
    assert_equal "123", manager.id
  end
end
