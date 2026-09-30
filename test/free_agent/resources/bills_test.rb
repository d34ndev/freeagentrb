require "test_helper"

class BillsResourceTest < Minitest::Test
  CONTACT = "https://api.freeagent.com/v2/contacts/1".freeze

  def test_list
    stub_api(:get, "bills", query: { view: "open" }, fixture: "bills/list_all_bills")

    bills = client.bills.list(view: "open")

    assert_equal FreeAgent::Collection, bills.class
    assert_equal FreeAgent::Bill, bills.first.class
    assert_equal "1", bills.first.id
  end

  def test_list_with_nested_bill_items
    stub_api(:get, "bills", query: { nested_bill_items: "true" }, fixture: "bills/list_all_bills_with_nested_bill_items")

    bills = client.bills.list(nested_bill_items: true)

    assert_equal "REF 001", bills.first.reference
    assert_equal FreeAgent::Object, bills.first.bill_items.first.class
  end

  def test_list_for_contact
    stub_api(:get, "bills", query: { contact: CONTACT }, fixture: "bills/list_all_bills")

    assert_equal FreeAgent::Bill, client.bills.list_for_contact(contact: CONTACT).first.class
  end

  def test_list_for_project
    project = "https://api.freeagent.com/v2/projects/2"
    stub_api(:get, "bills", query: { project: project }, fixture: "bills/list_all_bills")

    assert_equal FreeAgent::Bill, client.bills.list_for_project(project: project).first.class
  end

  def test_retrieve_coerces_monetary_values
    stub_api(:get, "bills/1", fixture: "bills/get_a_single_bill")

    bill = client.bills.retrieve(id: 1)

    assert_equal "REF100", bill.reference
    assert_equal 100.0, bill.total_value
    assert_equal(-83.33, bill.net_value)
    assert_equal 20.0, bill.due_value
    assert_equal "0.673193", bill.exchange_rate
  end

  def test_create_wraps_the_payload
    bill_items = [ { category: "https://api.freeagent.com/v2/categories/609", description: "Alex Gregory - Bill REF100", total_value: "100.0" } ]
    stub_api(:post, "bills",
      request_body: { bill: { contact: CONTACT, dated_on: "2020-09-14", due_on: "2020-10-14", reference: "REF100", bill_items: bill_items } },
      status: 201, fixture: "bills/create_a_bill")

    bill = client.bills.create(contact: CONTACT, dated_on: "2020-09-14", due_on: "2020-10-14", reference: "REF100", bill_items: bill_items)

    assert_equal "REF100", bill.reference
    assert_equal "1", bill.bill_items.first.id
  end

  def test_update_wraps_the_payload
    stub_api(:put, "bills/1", request_body: { bill: { reference: "REF101" } }, fixture: "bills/get_a_single_bill")

    assert_equal FreeAgent::Bill, client.bills.update(id: 1, reference: "REF101").class
  end

  def test_delete
    stub_api(:delete, "bills/1")

    assert_equal true, client.bills.delete(id: 1)
  end
end
