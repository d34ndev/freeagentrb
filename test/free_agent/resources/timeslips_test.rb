require "test_helper"

class TimeslipsResourceTest < Minitest::Test
  USER = "https://api.freeagent.com/v2/users/1".freeze
  PROJECT = "https://api.freeagent.com/v2/projects/1".freeze
  TASK = "https://api.freeagent.com/v2/tasks/1".freeze

  def test_list
    stub_api(:get, "timeslips", query: { from_date: "2012-01-01", to_date: "2012-03-31", view: "all" }, fixture: "timeslips/list_all_timeslips")

    assert_equal FreeAgent::Timeslip, client.timeslips.list(from_date: "2012-01-01", to_date: "2012-03-31", view: "all").first.class
  end

  def test_list_for_user_task_and_project
    stub_api(:get, "timeslips", query: { user: USER }, fixture: "timeslips/list_all_timeslips")
    stub_api(:get, "timeslips", query: { task: TASK }, fixture: "timeslips/list_all_timeslips")
    stub_api(:get, "timeslips", query: { project: PROJECT }, fixture: "timeslips/list_all_timeslips")

    assert_equal FreeAgent::Timeslip, client.timeslips.list_for_user(user: USER).first.class
    assert_equal FreeAgent::Timeslip, client.timeslips.list_for_task(task: TASK).first.class
    assert_equal FreeAgent::Timeslip, client.timeslips.list_for_project(project: PROJECT).first.class
  end

  def test_retrieve
    stub_api(:get, "timeslips/25", fixture: "timeslips/get_a_single_timeslip")

    timeslip = client.timeslips.retrieve(id: 25)

    assert_equal "12.0", timeslip.hours
    assert_equal "25", timeslip.id
  end

  def test_create_wraps_the_payload
    stub_api(:post, "timeslips",
      request_body: { timeslip: { task: TASK, user: USER, project: PROJECT, dated_on: "2011-08-15", hours: "12.0", comment: "Planning" } },
      status: 201, fixture: "timeslips/create_a_timeslip")

    timeslip = client.timeslips.create(task: TASK, user: USER, project: PROJECT, dated_on: "2011-08-15", hours: "12.0", comment: "Planning")

    assert_equal FreeAgent::Timeslip, timeslip.class
  end

  def test_create_many_sends_a_timeslips_array
    timeslips = [
      { task: TASK, user: USER, project: PROJECT, dated_on: "2011-08-15", hours: "12.0" },
      { task: TASK, user: USER, project: PROJECT, dated_on: "2011-08-16", hours: "6.0" }
    ]
    stub_api(:post, "timeslips", request_body: { timeslips: timeslips }, status: 201)

    assert_equal true, client.timeslips.create_many(timeslips: timeslips)
  end

  def test_update_wraps_the_payload
    stub_api(:put, "timeslips/25", request_body: { timeslip: { hours: "8.0" } }, fixture: "timeslips/get_a_single_timeslip")

    assert_equal FreeAgent::Timeslip, client.timeslips.update(id: 25, hours: "8.0").class
  end

  def test_delete
    stub_api(:delete, "timeslips/25")

    assert_equal true, client.timeslips.delete(id: 25)
  end

  def test_timers
    stub_api(:post, "timeslips/25/timer", request_body: {}, fixture: "timeslips/get_a_single_timeslip")
    stub_api(:delete, "timeslips/25/timer", fixture: "timeslips/get_a_single_timeslip")

    assert_equal FreeAgent::Timeslip, client.timeslips.start_timer(id: 25).class
    assert_equal true, client.timeslips.stop_timer(id: 25)
  end
end
