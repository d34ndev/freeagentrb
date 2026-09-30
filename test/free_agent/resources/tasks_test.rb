require "test_helper"

class TasksResourceTest < Minitest::Test
  PROJECT = "https://api.freeagent.com/v2/projects/1".freeze

  def test_list
    stub_api(:get, "tasks", query: { view: "active", updated_since: "2017-04-06" }, fixture: "tasks/list_all_tasks")

    assert_equal FreeAgent::Task, client.tasks.list(view: "active", updated_since: "2017-04-06").first.class
  end

  def test_list_for_project
    stub_api(:get, "tasks", query: { project: PROJECT }, fixture: "tasks/list_all_tasks")

    assert_equal FreeAgent::Task, client.tasks.list_for_project(project: PROJECT).first.class
  end

  def test_retrieve
    stub_api(:get, "tasks/1", fixture: "tasks/get_a_single_task")

    task = client.tasks.retrieve(id: 1)

    assert_equal "Sample Task", task.name
    assert_equal "GBP", task.currency
    assert_equal false, task.is_deletable
  end

  # The project goes in the query string, not the body
  def test_create_sends_the_project_in_the_query
    stub_api(:post, "tasks", query: { project: PROJECT }, request_body: { task: { name: "Sample Task", is_billable: true } },
      status: 201, fixture: "tasks/create_a_task_under_a_certain_project")

    assert_equal FreeAgent::Task, client.tasks.create(project: PROJECT, name: "Sample Task", is_billable: true).class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "tasks/1", request_body: { task: { name: "Renamed" } }, fixture: "tasks/get_a_single_task")

    assert_equal FreeAgent::Task, client.tasks.update(id: 1, name: "Renamed").class
  end

  def test_delete
    stub_api(:delete, "tasks/1")

    assert_equal true, client.tasks.delete(id: 1)
  end
end
