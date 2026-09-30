module FreeAgent
  class Client
    BASE_URL = "https://api.freeagent.com/v2"
    SANDBOX_BASE_URL = "https://api.sandbox.freeagent.com/v2"

    attr_reader :access_token, :sandbox, :subdomain, :api_version, :adapter, :rate_limiter

    # api_version is sent as the X-Api-Version header, a date such as
    # "2026-09-01". Without it, FreeAgent serves each endpoint's original version.
    def initialize(access_token:, sandbox: false, subdomain: nil, api_version: nil, adapter: Faraday.default_adapter, stubs: nil, logger: nil, enable_rate_limit_test: false)
      @access_token = access_token
      @sandbox = sandbox
      @subdomain = subdomain
      @api_version = api_version
      @adapter = adapter
      @logger = logger
      @enable_rate_limit_test = enable_rate_limit_test

      # Test stubs for requests
      @stubs = stubs

      # Initialize rate limiter
      @rate_limiter = FreeAgent::RateLimiter.new(logger: logger)
    end

    # Returns a new client scoped to one of the practice's clients, so that
    # requests are made on their behalf via the X-Subdomain header.
    def on_behalf_of(subdomain)
      self.class.new(
        access_token: access_token,
        sandbox: sandbox,
        subdomain: subdomain,
        api_version: api_version,
        adapter: adapter,
        stubs: @stubs,
        logger: @logger,
        enable_rate_limit_test: @enable_rate_limit_test
      )
    end

    def company
      CompanyResource.new(self)
    end

    def contacts
      ContactsResource.new(self)
    end

    def bank_accounts
      BankAccountsResource.new(self)
    end

    def bank_transactions
      BankTransactionsResource.new(self)
    end

    def bank_transaction_explanations
      BankTransactionExplanationsResource.new(self)
    end

    def projects
      ProjectsResource.new(self)
    end

    def tasks
      TasksResource.new(self)
    end

    def timeslips
      TimeslipsResource.new(self)
    end

    def users
      UsersResource.new(self)
    end

    def attachments
      AttachmentsResource.new(self)
    end

    def invoices
      InvoicesResource.new(self)
    end

    def estimates
      EstimatesResource.new(self)
    end

    def estimate_items
      EstimateItemsResource.new(self)
    end

    def credit_notes
      CreditNotesResource.new(self)
    end

    def bills
      BillsResource.new(self)
    end

    def categories
      CategoriesResource.new(self)
    end

    def expenses
      ExpensesResource.new(self)
    end

    def clients
      ClientsResource.new(self)
    end

    def account_managers
      AccountManagersResource.new(self)
    end

    def practice
      PracticeResource.new(self)
    end

    def recurring_invoices
      RecurringInvoicesResource.new(self)
    end

    def price_list_items
      PriceListItemsResource.new(self)
    end

    def credit_note_reconciliations
      CreditNoteReconciliationsResource.new(self)
    end

    def stock_items
      StockItemsResource.new(self)
    end

    def journal_sets
      JournalSetsResource.new(self)
    end

    def transactions
      TransactionsResource.new(self)
    end

    def notes
      NotesResource.new(self)
    end

    def bank_feeds
      BankFeedsResource.new(self)
    end

    def email_addresses
      EmailAddressesResource.new(self)
    end

    def account_locks
      AccountLocksResource.new(self)
    end

    def capital_assets
      CapitalAssetsResource.new(self)
    end

    def capital_asset_types
      CapitalAssetTypesResource.new(self)
    end

    def hire_purchases
      HirePurchasesResource.new(self)
    end

    def balance_sheet
      BalanceSheetResource.new(self)
    end

    def profit_and_loss
      ProfitAndLossResource.new(self)
    end

    def trial_balance
      TrialBalanceResource.new(self)
    end

    def cashflow
      CashflowResource.new(self)
    end

    def final_accounts_reports
      FinalAccountsReportsResource.new(self)
    end

    def vat_returns
      VatReturnsResource.new(self)
    end

    def corporation_tax_returns
      CorporationTaxReturnsResource.new(self)
    end

    def self_assessment_returns
      SelfAssessmentReturnsResource.new(self)
    end

    def sales_tax_periods
      SalesTaxPeriodsResource.new(self)
    end

    def cis_bands
      CisBandsResource.new(self)
    end

    def payroll
      PayrollResource.new(self)
    end

    def payroll_profiles
      PayrollProfilesResource.new(self)
    end

    def properties
      PropertiesResource.new(self)
    end

    def connection
      url = (sandbox == true ? SANDBOX_BASE_URL : BASE_URL)
      @connection ||= Faraday.new(url) do |conn|
        conn.request :authorization, :Bearer, access_token
        conn.request :json
        conn.response :json

        conn.headers = {
          "User-Agent" => "freeagentrb/v#{VERSION} (github.com/deanpcmad/freeagentrb)"
        }

        # Make requests on behalf of a practice client
        conn.headers["X-Subdomain"] = subdomain if subdomain

        conn.headers["X-Api-Version"] = api_version if api_version

        # Add X-RateLimit-Test header if enabled (for testing in sandbox)
        conn.headers["X-RateLimit-Test"] = "true" if @enable_rate_limit_test

        conn.adapter adapter, @stubs
      end
    end

    # Uses Faraday Multipart (lostisland/faraday-multipart)
    def connection_upload
      url = (sandbox == true ? SANDBOX_BASE_URL : BASE_URL)
      @connection_upload ||= Faraday.new(url) do |conn|
        conn.request :authorization, :Bearer, access_token
        conn.request :multipart

        conn.headers["User-Agent"] = "freeagentrb/v#{VERSION} (github.com/deanpcmad/freeagentrb)"
        conn.headers["X-Subdomain"] = subdomain if subdomain
        conn.headers["X-Api-Version"] = api_version if api_version
      end
    end
  end
end
