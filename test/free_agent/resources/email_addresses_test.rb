require "test_helper"

class EmailAddressesResourceTest < Minitest::Test
  def test_list_returns_an_array_of_addresses
    stub_api(:get, "email_addresses", fixture: "email_addresses/get_a_list_of_verified_sender_email_addresses")

    assert_equal [ "John Smith <jsmith@example.com>" ], client.email_addresses.list
  end
end
