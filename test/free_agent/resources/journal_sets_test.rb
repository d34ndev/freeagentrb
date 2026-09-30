require "test_helper"

class JournalSetsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "journal_sets", query: { from_date: "2012-01-01", to_date: "2012-03-31", tag: "MYAPPTAG" }, fixture: "journal_sets/list_all_journal_sets")

    journal_set = client.journal_sets.list(from_date: "2012-01-01", to_date: "2012-03-31", tag: "MYAPPTAG").first

    assert_equal FreeAgent::JournalSet, journal_set.class
  end

  def test_retrieve
    stub_api(:get, "journal_sets/1", fixture: "journal_sets/get_a_single_journal_set")

    journal_set = client.journal_sets.retrieve(id: 1)

    assert_equal "MYAPPTAG", journal_set.tag
    assert_equal "-123.45", journal_set.journal_entries.first.debit_value
  end

  def test_opening_balances
    stub_api(:get, "journal_sets/opening_balances", fixture: "journal_sets/get_the_opening_balances")

    journal_set = client.journal_sets.opening_balances

    assert_equal FreeAgent::JournalSet, journal_set.class
    assert_equal "Default bank account", journal_set.bank_accounts.first.description
    assert_equal "3", journal_set.journal_entries.first.id
  end

  def test_create_wraps_the_payload
    entries = [
      { category: "https://api.freeagent.com/v2/categories/001", description: "A Sales Correction", debit_value: "-123.45" },
      { category: "https://api.freeagent.com/v2/categories/901", user: "https://api.freeagent.com/v2/users/1", description: "Director's Capital Introduced", debit_value: "123.45" }
    ]
    stub_api(:post, "journal_sets",
      request_body: { journal_set: { dated_on: "2011-07-28", description: "An example journal set", journal_entries: entries, tag: "MYAPPTAG" } },
      status: 201, fixture: "journal_sets/create_a_journal_set")

    journal_set = client.journal_sets.create(dated_on: "2011-07-28", description: "An example journal set", journal_entries: entries, tag: "MYAPPTAG")

    assert_equal 2, journal_set.journal_entries.count
  end

  # Entries are removed with _destroy, changed by url, or added without one
  def test_update_sends_entry_changes
    entries = [
      { url: "https://api.freeagent.com/v2/journal_sets/37/journal_entries/17", _destroy: true },
      { url: "https://api.freeagent.com/v2/journal_sets/37/journal_entries/18", debit_value: "-20.0" },
      { category: "https://api.freeagent.com/v2/categories/001", debit_value: "-20.0" }
    ]
    stub_api(:put, "journal_sets/37", request_body: { journal_set: { journal_entries: entries } }, fixture: "journal_sets/get_a_single_journal_set")

    assert_equal FreeAgent::JournalSet, client.journal_sets.update(id: 37, journal_entries: entries).class
  end

  def test_delete
    stub_api(:delete, "journal_sets/37")

    assert_equal true, client.journal_sets.delete(id: 37)
  end
end
