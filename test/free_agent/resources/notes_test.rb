require "test_helper"

class NotesResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/1".freeze
  PROJECT = "https://api.freeagent.com/v2/projects/1".freeze

  def test_list_for_contact
    stub_api(:get, "notes", query: { contact: CONTACT }, fixture: "notes/list_all_notes_for_a_contact")

    note = client.notes.list_for_contact(contact: CONTACT).first

    assert_equal FreeAgent::Note, note.class
    assert_equal "A new note", note.note
  end

  def test_list_for_project
    stub_api(:get, "notes", query: { project: PROJECT }, fixture: "notes/list_all_notes_for_a_project")

    assert_equal FreeAgent::Note, client.notes.list_for_project(project: PROJECT).first.class
  end

  def test_retrieve
    stub_api(:get, "notes/1", fixture: "notes/get_a_single_note")

    assert_equal "Development Team", client.notes.retrieve(id: 1).author
  end

  # The parent goes in the query string, not the body
  def test_create_for_a_contact
    stub_api(:post, "notes", query: { contact: CONTACT }, request_body: { note: { note: "A new note" } }, fixture: "notes/create_a_note_for_a_contact")

    assert_equal "A new note", client.notes.create(note: "A new note", contact: CONTACT).note
  end

  def test_create_for_a_project
    stub_api(:post, "notes", query: { project: PROJECT }, request_body: { note: { note: "A new note" } }, fixture: "notes/create_a_note_for_a_project")

    assert_equal FreeAgent::Note, client.notes.create(note: "A new note", project: PROJECT).class
  end

  def test_update_wraps_the_payload
    stub_api(:put, "notes/1", request_body: { note: { note: "A new note" } }, fixture: "notes/update_a_note")

    assert_equal FreeAgent::Note, client.notes.update(id: 1, note: "A new note").class
  end

  def test_delete
    stub_api(:delete, "notes/1")

    assert_equal true, client.notes.delete(id: 1)
  end
end
