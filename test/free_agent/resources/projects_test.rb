require "test_helper"

class ProjectsResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/1".freeze

  def test_list
    stub_api(:get, "projects", query: { view: "active", nested: "true" }, fixture: "projects/list_all_projects")

    project = client.projects.list(view: "active", nested: true).first

    assert_equal FreeAgent::Project, project.class
  end

  def test_list_for_contact
    stub_api(:get, "projects", query: { contact: CONTACT }, fixture: "projects/list_all_projects")

    assert_equal FreeAgent::Project, client.projects.list_for_contact(contact: CONTACT).first.class
  end

  def test_retrieve
    stub_api(:get, "projects/1", fixture: "projects/get_a_single_project")

    project = client.projects.retrieve(id: 1)

    assert_equal "Test Project", project.name
    assert_equal "Acme Trading", project.contact_name
  end

  def test_create_wraps_the_payload
    stub_api(:post, "projects",
      request_body: { project: { contact: CONTACT, name: "Test Project", status: "Active", currency: "GBP", budget_units: "Hours" } },
      status: 201, fixture: "projects/create_a_project")

    project = client.projects.create(contact: CONTACT, name: "Test Project", status: "Active", currency: "GBP", budget_units: "Hours")

    assert_equal FreeAgent::Project, project.class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "projects/1", request_body: { project: { name: "Renamed" } }, fixture: "projects/get_a_single_project")

    assert_equal FreeAgent::Project, client.projects.update(id: 1, name: "Renamed").class
  end

  def test_delete
    stub_api(:delete, "projects/1")

    assert_equal true, client.projects.delete(id: 1)
  end
end
