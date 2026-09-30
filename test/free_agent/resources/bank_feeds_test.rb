require "test_helper"

class BankFeedsResourceTest < Minitest::Test
  def test_list
    stub_api(:get, "bank_feeds", fixture: "bank_feeds/reading_the_list_of_bank_feeds_for_a_company")

    bank_feeds = client.bank_feeds.list

    assert_equal FreeAgent::BankFeed, bank_feeds.first.class
    assert_equal "Mettle", bank_feeds.first.bank_service_name
    assert_equal "open_banking", bank_feeds.last.feed_type
  end

  def test_retrieve
    stub_api(:get, "bank_feeds/7", fixture: "bank_feeds/reading_an_api_bank_feed")

    bank_feed = client.bank_feeds.retrieve(id: 7)

    assert_equal FreeAgent::BankFeed, bank_feed.class
    assert_equal "enabled", bank_feed.state
  end

  def test_retrieve_raises_when_not_found
    stub_api(:get, "bank_feeds/99", status: 404, body: { errors: { error: { message: "Resource not found" } } })

    assert_raises(FreeAgent::Errors::EntityNotFoundError) { client.bank_feeds.retrieve(id: 99) }
  end
end
