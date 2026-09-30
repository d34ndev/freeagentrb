require "test_helper"

class UsersResourceTest < Minitest::Test
  def test_me
    stub_api(:get, "users/me", fixture: "users/get_a_single_user")

    me = client.users.me

    assert_equal FreeAgent::User, me.class
    assert_equal "Development", me.first_name
    assert_equal 8, me.permission_level
  end

  def test_list
    stub_api(:get, "users", query: { view: "all" }, fixture: "users/list_all_users")

    users = client.users.list(view: "all")

    assert_equal FreeAgent::Collection, users.class
    assert_equal FreeAgent::User, users.first.class
  end

  def test_retrieve
    stub_api(:get, "users/1", fixture: "users/get_a_single_user")

    assert_equal "dev@example.com", client.users.retrieve(id: 1).email
  end

  def test_create_wraps_the_payload
    stub_api(:post, "users",
      request_body: { user: { email: "dev@example.com", first_name: "Development", last_name: "Team", role: "Director", opening_mileage: 0, permission_level: 8 } },
      status: 201, fixture: "users/create_a_user")

    user = client.users.create(email: "dev@example.com", first_name: "Development", last_name: "Team", role: "Director", permission_level: 8)

    assert_equal FreeAgent::User, user.class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "users/1", request_body: { user: { role: "Employee" } }, fixture: "users/get_a_single_user")

    assert_equal FreeAgent::User, client.users.update(id: 1, role: "Employee").class
  end

  def test_update_me_wraps_the_payload
    stub_api(:put, "users/me", request_body: { user: { first_name: "Dev" } }, fixture: "users/get_a_single_user")

    assert_equal FreeAgent::User, client.users.update_me(first_name: "Dev").class
  end

  def test_delete
    stub_api(:delete, "users/1")

    assert_equal true, client.users.delete(id: 1)
  end
end
