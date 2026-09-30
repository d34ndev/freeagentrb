require "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    @client = FreeAgent::Client.new(access_token: "test_token", sandbox: true)
  end

  def test_client_initialization_with_sandbox
    client = FreeAgent::Client.new(access_token: "test_token", sandbox: true)

    assert_equal "test_token", client.access_token
    assert_equal true, client.sandbox
  end

  def test_client_initialization_without_sandbox
    client = FreeAgent::Client.new(access_token: "test_token")

    assert_equal "test_token", client.access_token
    assert_equal false, client.sandbox
  end

  def test_client_has_all_resource_methods
    expected_resources = [
      :company, :contacts, :bank_accounts, :bank_transactions,
      :bank_transaction_explanations, :projects, :tasks, :timeslips,
      :users, :attachments, :invoices, :estimates, :estimate_items,
      :credit_notes, :bills, :categories
    ]

    expected_resources.each do |resource|
      assert_respond_to @client, resource, "Client should respond to #{resource}"
    end
  end

  def test_connection_configuration
    connection = @client.connection

    assert_instance_of Faraday::Connection, connection
    assert_includes connection.url_prefix.to_s, "sandbox.freeagent.com" if @client.sandbox
  end

  def test_user_agent_header
    connection = @client.connection

    assert_includes connection.headers["User-Agent"], "freeagentrb"
    assert_includes connection.headers["User-Agent"], FreeAgent::VERSION
  end

  # def test_authorization_header_is_set
  #   connection = @client.connection

  #   assert connection.headers.key?("Authorization")
  # end

  # def test_api_workflow_bank_accounts
  #   accounts = @client.bank_accounts.list

  #   assert_instance_of FreeAgent::Collection, accounts

  #   if accounts.any?
  #     first_account = accounts.first
  #     assert_instance_of FreeAgent::BankAccount, first_account

  #     retrieved_account = @client.bank_accounts.retrieve(id: first_account.id)
  #     assert_instance_of FreeAgent::BankAccount, retrieved_account
  #     assert_equal first_account.id, retrieved_account.id
  #   end
  # end

  # def test_company_resource_integration
  #   company = @client.company.retrieve

  #   if company
  #     assert_instance_of FreeAgent::Company, company
  #     assert_respond_to company, :name
  #   end
  # end

  # def test_error_handling_integration
  #   assert_raises(FreeAgent::Errors::EntityNotFoundError) do
  #     @client.bank_accounts.retrieve(id: "nonexistent_id")
  #   end
  # end
end
