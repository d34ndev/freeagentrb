require "test_helper"

class ContactsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "contacts", query: { view: "active", sort: "-updated_at", updated_since: "2025-03-15T09:00:00.000Z" },
      fixture: "contacts/list_all_contacts")

    contacts = client.contacts.list(view: "active", sort: "-updated_at", updated_since: "2025-03-15T09:00:00.000Z")

    assert_equal FreeAgent::Collection, contacts.class
    assert_equal FreeAgent::Contact, contacts.first.class
    assert_equal "Acme Ltd", contacts.first.organisation_name
    assert_equal "2", contacts.first.id
  end

  def test_retrieve
    stub_api(:get, "contacts/2", fixture: "contacts/get_a_single_contact")

    contact = client.contacts.retrieve(id: 2)

    assert_equal FreeAgent::Contact, contact.class
    assert_equal "test", contact.first_name
    assert_equal true, contact.is_cis_subcontractor
  end

  def test_create_wraps_the_payload
    stub_api(:post, "contacts", request_body: { contact: { first_name: "test", last_name: "me", email: "test@example.com" } },
      status: 201, fixture: "contacts/create_a_contact")

    contact = client.contacts.create(first_name: "test", last_name: "me", email: "test@example.com")

    assert_equal FreeAgent::Contact, contact.class
    assert_equal "70", contact.id
  end

  def test_create_requires_a_name
    assert_raises(RuntimeError) { client.contacts.create(email: "test@example.com") }
  end

  def test_update_wraps_the_payload
    stub_api(:put, "contacts/2", request_body: { contact: { organisation_name: "Acme Ltd" } }, fixture: "contacts/get_a_single_contact")

    assert_equal "Acme Ltd", client.contacts.update(id: 2, organisation_name: "Acme Ltd").organisation_name
  end

  def test_delete
    stub_api(:delete, "contacts/2")

    assert_equal true, client.contacts.delete(id: 2)
  end
end
