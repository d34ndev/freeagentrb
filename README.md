# FreeAgentRB

FreeAgentRB is the easiest and most complete Ruby library for the FreeAgent v2 API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "freeagentrb"
```

## Usage

### Set Client Details

Firstly you'll need to set an Access Token, which would be created from OAuth.
See [this page](https://dev.freeagent.com/docs/quick_start) for more info.

```ruby
@client = FreeAgent::Client.new(access_token: "", sandbox: true)
```

### API Versions

FreeAgent versions breaking changes by date. Without a version, each endpoint
behaves as it did before versioning was introduced. To opt in to a newer
version, pass `api_version`, which is sent as the `X-Api-Version` header. See
[the FreeAgent docs](https://dev.freeagent.com/docs/versioning) for more info.

```ruby
@client = FreeAgent::Client.new(access_token: "", api_version: "2026-09-01")
```

### Rate Limiting

The library automatically tracks rate limiting based on the FreeAgent API's `Retry-After` header when you receive a 429 (Too Many Requests) response. You can access rate limit information through the client's rate limiter:

```ruby
# Initialize with optional logger
require "logger"
logger = Logger.new($stdout)
@client = FreeAgent::Client.new(access_token: "", sandbox: true, logger: logger)

# Check rate limit status
@client.rate_limiter.status
# => "Not rate limited" or "Rate limited. Retry in 60 seconds"

# Check if currently rate limited
@client.rate_limiter.rate_limited?
# => true/false

# Get seconds until rate limit resets
@client.rate_limiter.reset_in
# => 60 (seconds remaining)

# Manually wait if rate limited
@client.rate_limiter.wait_if_rate_limited
```

For testing rate limiting in the sandbox, enable the `X-RateLimit-Test` header:

```ruby
# This artificially lowers sandbox API calls to 5 requests/minute
@client = FreeAgent::Client.new(
  access_token: "",
  sandbox: true,
  enable_rate_limit_test: true
)
```

### OAuth

This library includes the ability to create, refresh and revoke OAuth tokens.

```ruby
# Firstly, set the client details
@oauth = FreeAgent::OAuth.new(sandbox: true, client_id: "", client_secret: "")

# Generate an authorisation URL
# state can be nil
@oauth.authorise_url(redirect: "https://mysite.com/auth", state: "something")

# Create a Token from the authorisation code
@oauth.create(token: "abc123", redirect: "https://mysite.com/auth")

# Refresh a Token
@oauth.refresh(refresh_token: "abc123")
```


## Resources

Methods that return a list give you a `FreeAgent::Collection`, which responds
to `each`, `count`, `first` and `last`, along with `total` (from the
`X-Total-Count` header) and `pagination` (from the `Link` header).

Any extra keyword arguments are passed through to the API as query parameters
on list methods, or as attributes on create and update, so anything documented
by FreeAgent that isn't named below can still be sent.

Attributes that reference another record are given as full URLs, e.g.
`contact: "https://api.freeagent.com/v2/contacts/1"`.

### Company

```ruby
@client.company.retrieve
```

### Contacts

```ruby
@client.contacts.list
@client.contacts.list(view: "active")
@client.contacts.retrieve(id: "12345")
@client.contacts.create first_name: "Dwight", last_name: "Schrute"
@client.contacts.update id: "12345", first_name: "Dwight Kurt"
@client.contacts.delete id: "12345"
```

### Users

```ruby
@client.users.me
@client.users.update_me first_name: "Dwight"

@client.users.list
@client.users.retrieve(id: "12345")
@client.users.create email: "dwight@example.com", first_name: "Dwight", last_name: "Schrute", role: "Director"
@client.users.update id: "12345", role: "Employee"
@client.users.delete id: "12345"
```

### Bank Accounts

```ruby
@client.bank_accounts.list
@client.bank_accounts.list(view: "paypal_accounts")
@client.bank_accounts.retrieve(id: "12345")
@client.bank_accounts.create type: "StandardBankAccount", name: "My Account", opening_balance: "10"
@client.bank_accounts.update id: "12345", name: "My Other Account"
@client.bank_accounts.delete id: "12345"
```

### Bank Transactions

A bank account is required when listing.

```ruby
@client.bank_transactions.list bank_account: "https://api.freeagent.com/v2/bank_accounts/1"
@client.bank_transactions.list bank_account: "...", view: "unexplained"
@client.bank_transactions.retrieve(id: "12345")
@client.bank_transactions.delete id: "12345"

# Upload a statement as an array of transactions
@client.bank_transactions.create bank_account: "...", statement: [
  { dated_on: "2026-08-15", amount: "100.0", description: "Payment" }
]

# Or upload a statement file (OFX, QIF, CSV)
@client.bank_transactions.upload bank_account: "...", statement: "statement.csv"
```

### Bank Transaction Explanations

```ruby
@client.bank_transaction_explanations.list bank_account: "https://api.freeagent.com/v2/bank_accounts/1"
@client.bank_transaction_explanations.retrieve(id: "12345")
@client.bank_transaction_explanations.create bank_transaction: "...", dated_on: "2026-08-15", gross_value: "-100.0", category: "..."
@client.bank_transaction_explanations.update id: "12345", description: "Hosting"
@client.bank_transaction_explanations.delete id: "12345"

# File attachments, up to 50 per explanation. These endpoints always send
# X-Api-Version 2026-09-01 or later.
@client.bank_transaction_explanations.attachments id: "12345"
@client.bank_transaction_explanations.add_attachments id: "12345", attachments: [
  { data: Base64.strict_encode64(File.binread("receipt.png")), file_name: "receipt.png", content_type: "image/png" }
]
@client.bank_transaction_explanations.update_attachments id: "12345", attachments: [
  { url: "https://api.freeagent.com/v2/attachments/1", description: "Printer receipt" },
  { url: "https://api.freeagent.com/v2/attachments/2", _destroy: true }
]
@client.bank_transaction_explanations.delete_attachments id: "12345"
```

From 1 December 2026, explanations return an `attachments` array instead of a
single `attachment`, and attachments can only be changed through the endpoints
above.

### Projects

```ruby
@client.projects.list
@client.projects.list(view: "active")
@client.projects.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.projects.retrieve(id: "12345")
@client.projects.create contact: "...", name: "My Project", status: "Active", currency: "GBP", budget_units: "Hours"
@client.projects.update id: "12345", name: "Renamed Project"
@client.projects.delete id: "12345"
```

### Tasks

```ruby
@client.tasks.list
@client.tasks.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.tasks.retrieve(id: "12345")
@client.tasks.create project: "...", name: "My Task", currency: "GBP", is_billable: true, status: "Active"
@client.tasks.update id: "12345", name: "Renamed Task"
@client.tasks.delete id: "12345"
```

### Timeslips

```ruby
@client.timeslips.list
@client.timeslips.list(from_date: "2026-01-01", to_date: "2026-01-31")
@client.timeslips.list_for_user user: "https://api.freeagent.com/v2/users/1"
@client.timeslips.list_for_task task: "https://api.freeagent.com/v2/tasks/1"
@client.timeslips.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.timeslips.retrieve(id: "12345")
@client.timeslips.create task: "...", user: "...", project: "...", dated_on: "2026-08-15", hours: "7.5"
@client.timeslips.update id: "12345", hours: "8.0"
@client.timeslips.delete id: "12345"

@client.timeslips.start_timer id: "12345"
@client.timeslips.stop_timer id: "12345"
```

### Invoices

```ruby
@client.invoices.list
@client.invoices.list(view: "open", nested_invoice_items: true)
@client.invoices.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.invoices.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.invoices.retrieve(id: "12345")

@client.invoices.create contact: "...", dated_on: "2026-08-15", payment_terms_in_days: 30, invoice_items: [
  { description: "Consultancy", item_type: "Hours", price: "100.0", quantity: "10.0" }
]

@client.invoices.update id: "12345", reference: "002"
@client.invoices.delete id: "12345"
@client.invoices.duplicate id: "12345"

# Returns a Base64-encoded PDF
@client.invoices.retrieve_pdf id: "12345"

@client.invoices.email id: "12345", to: "someone@example.com", subject: "Your invoice"

@client.invoices.mark_as_sent id: "12345"
@client.invoices.mark_as_scheduled id: "12345"
@client.invoices.mark_as_draft id: "12345"
@client.invoices.mark_as_cancelled id: "12345"
@client.invoices.convert_to_credit_note id: "12345"
@client.invoices.direct_debit id: "12345"

# Recent activity across all invoices
@client.invoices.timeline

# The text added to the bottom of every new invoice
@client.invoices.default_additional_text
@client.invoices.update_default_additional_text "Thanks for your business"
@client.invoices.delete_default_additional_text
```

`net_value`, `total_value`, `paid_value`, `due_value` and `sales_tax_value` are
returned as floats rather than the strings the API sends. The same applies to
credit notes, bills, estimates and expenses.

### Estimates

```ruby
@client.estimates.list
@client.estimates.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.estimates.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.estimates.list_for_invoice invoice: "https://api.freeagent.com/v2/invoices/1"
@client.estimates.retrieve(id: "12345")
@client.estimates.create contact: "...", dated_on: "2026-08-15", currency: "GBP", reference: "001"
@client.estimates.update id: "12345", reference: "002"
@client.estimates.delete id: "12345"

# Returns a Base64-encoded PDF
@client.estimates.retrieve_pdf id: "12345"

@client.estimates.email id: "12345", to: "someone@example.com"

@client.estimates.mark_as_sent id: "12345"
@client.estimates.mark_as_draft id: "12345"
@client.estimates.mark_as_approved id: "12345"
@client.estimates.mark_as_rejected id: "12345"
@client.estimates.convert_to_invoice id: "12345"
```

### Estimate Items

```ruby
@client.estimate_items.create estimate: "https://api.freeagent.com/v2/estimates/1",
  item_type: "Hours", quantity: "10.0", price: "100.0", description: "Consultancy"
@client.estimate_items.update id: "12345", description: "Updated"
@client.estimate_items.delete id: "12345"
```

### Recurring Invoices

Read-only.

```ruby
@client.recurring_invoices.list
@client.recurring_invoices.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.recurring_invoices.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.recurring_invoices.retrieve(id: "12345")
```

### Price List Items

```ruby
@client.price_list_items.list
@client.price_list_items.retrieve(id: "12345")
@client.price_list_items.create code: "CONS", quantity: "1.0", item_type: "Hours",
  description: "Consultancy", price: "100.0"
@client.price_list_items.update id: "12345", price: "120.0"
@client.price_list_items.delete id: "12345"
```

### Stock Items

Read-only.

```ruby
@client.stock_items.list
@client.stock_items.retrieve(id: "12345")
```

### Credit Notes

```ruby
@client.credit_notes.list
@client.credit_notes.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.credit_notes.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.credit_notes.retrieve(id: "12345")
@client.credit_notes.create contact: "...", dated_on: "2026-08-15", payment_terms_in_days: 30
@client.credit_notes.update id: "12345", reference: "002"
@client.credit_notes.delete id: "12345"

# Returns a Base64-encoded PDF
@client.credit_notes.retrieve_pdf id: "12345"

@client.credit_notes.email id: "12345", to: "someone@example.com"

@client.credit_notes.mark_as_sent id: "12345"
@client.credit_notes.mark_as_draft id: "12345"
@client.credit_notes.mark_as_cancelled id: "12345"
```

### Credit Note Reconciliations

```ruby
@client.credit_note_reconciliations.list
@client.credit_note_reconciliations.retrieve(id: "12345")
@client.credit_note_reconciliations.create credit_note: "https://api.freeagent.com/v2/credit_notes/1",
  invoice: "https://api.freeagent.com/v2/invoices/2", value: "50.0"
@client.credit_note_reconciliations.update id: "12345", value: "75.0"
@client.credit_note_reconciliations.delete id: "12345"
```

### Bills

```ruby
@client.bills.list
@client.bills.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.bills.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.bills.retrieve(id: "12345")

@client.bills.create contact: "...", dated_on: "2026-08-15", due_on: "2026-09-15", reference: "Bill-001", bill_items: [
  { description: "Stationery", category: "https://api.freeagent.com/v2/categories/285", total_value: "100.0" }
]

@client.bills.update id: "12345", reference: "Bill-002"
@client.bills.delete id: "12345"
```

### Expenses

```ruby
@client.expenses.list
@client.expenses.list(from_date: "2026-01-01", to_date: "2026-01-31")
@client.expenses.list_for_user user: "https://api.freeagent.com/v2/users/1"
@client.expenses.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.expenses.retrieve(id: "12345")

@client.expenses.create user: "...", category: "https://api.freeagent.com/v2/categories/285",
  dated_on: "2026-08-15", gross_value: "-12.0", description: "Train fare"

# Mileage expenses use the Mileage category
@client.expenses.create user: "...", category: "Mileage", dated_on: "2026-08-15",
  mileage: 100, vehicle_type: "Car"

@client.expenses.update id: "12345", description: "Updated"
@client.expenses.delete id: "12345"

@client.expenses.mileage_settings
```

### Journal Sets

```ruby
@client.journal_sets.list
@client.journal_sets.opening_balances
@client.journal_sets.retrieve(id: "12345")

@client.journal_sets.create dated_on: "2026-08-15", description: "Adjustment", journal_entries: [
  { category: "https://api.freeagent.com/v2/categories/285", debit_value: "100.0", description: "Stationery" },
  { category: "https://api.freeagent.com/v2/categories/750", debit_value: "-100.0", description: "Stationery" }
]

@client.journal_sets.update id: "12345", description: "Updated"
@client.journal_sets.delete id: "12345"
```

### Transactions

The general ledger, as opposed to bank transactions. Read-only, and date
ranges must span 12 months or less.

```ruby
@client.transactions.list
@client.transactions.list from_date: "2026-01-01", to_date: "2026-06-30"
@client.transactions.retrieve(id: "12345")
```

### Notes

The parent record goes in the query string rather than the body, so pass
either `contact:` or `project:`.

```ruby
@client.notes.list_for_contact contact: "https://api.freeagent.com/v2/contacts/1"
@client.notes.list_for_project project: "https://api.freeagent.com/v2/projects/1"
@client.notes.retrieve(id: "12345")
@client.notes.create note: "Called them", contact: "https://api.freeagent.com/v2/contacts/1"
@client.notes.update id: "12345", note: "Updated"
@client.notes.delete id: "12345"
```

### Bank Feeds

Read-only.

```ruby
@client.bank_feeds.list
@client.bank_feeds.retrieve(id: "12345")
```

### Email Addresses

Verified sender addresses, returned as a plain `Array` of strings.

```ruby
@client.email_addresses.list
# => ["me@example.com"]
```

### Account Locks

```ruby
@client.account_locks.retrieve
@client.account_locks.update locked_until: "2026-03-31"
@client.account_locks.delete
```

### Categories

Unlike other resources this returns a plain `Array`, with each category tagged
with the `category_type` it was listed under.

```ruby
@client.categories.list
# => [#<FreeAgent::Category description="Accommodation and Travel",
#      nominal_code="250", category_type="admin_expenses_categories">, ...]
```

### Capital Assets

Read-only.

```ruby
@client.capital_assets.list
@client.capital_assets.list include_history: true
@client.capital_assets.retrieve(id: "12345")
```

### Capital Asset Types

```ruby
@client.capital_asset_types.list
@client.capital_asset_types.retrieve(id: "12345")
@client.capital_asset_types.create name: "Computer Equipment"
@client.capital_asset_types.update id: "12345", name: "Vehicles"
@client.capital_asset_types.delete id: "12345"
```

### Hire Purchases

Read-only.

```ruby
@client.hire_purchases.list
@client.hire_purchases.retrieve(id: "12345")
```

### Reports

All read-only. Each returns a `FreeAgent::Collection` of line items.

```ruby
@client.balance_sheet.retrieve period_ends_on: "2026-03-31"
@client.balance_sheet.opening_balances

@client.profit_and_loss.summary from_date: "2026-01-01", to_date: "2026-03-31"

@client.trial_balance.summary
@client.trial_balance.opening_balances

@client.cashflow.retrieve
```

### Final Accounts Reports

Reports are identified by the date their accounting period ends, not by an id.

```ruby
@client.final_accounts_reports.list
@client.final_accounts_reports.retrieve period_ends_on: "2026-03-31"
@client.final_accounts_reports.mark_as_filed period_ends_on: "2026-03-31"
@client.final_accounts_reports.mark_as_unfiled period_ends_on: "2026-03-31"
```

### VAT Returns

Read-only, and identified by the date their period ends. Payments are marked
paid individually.

```ruby
@client.vat_returns.list
@client.vat_returns.retrieve period_ends_on: "2026-03-31"
@client.vat_returns.mark_as_filed period_ends_on: "2026-03-31"
@client.vat_returns.mark_as_unfiled period_ends_on: "2026-03-31"
@client.vat_returns.mark_payment_as_paid period_ends_on: "2026-03-31", payment_id: "12345"
@client.vat_returns.mark_payment_as_unpaid period_ends_on: "2026-03-31", payment_id: "12345"
```

### Corporation Tax Returns

```ruby
@client.corporation_tax_returns.list
@client.corporation_tax_returns.retrieve period_ends_on: "2026-03-31"
@client.corporation_tax_returns.mark_as_filed period_ends_on: "2026-03-31"
@client.corporation_tax_returns.mark_as_unfiled period_ends_on: "2026-03-31"
@client.corporation_tax_returns.mark_as_paid period_ends_on: "2026-03-31"
@client.corporation_tax_returns.mark_as_unpaid period_ends_on: "2026-03-31"
```

### Self Assessment Returns

Nested under a user. The Income Tax Returns docs page describes these same
endpoints.

```ruby
@client.self_assessment_returns.list user_id: "12345"
@client.self_assessment_returns.retrieve user_id: "12345", period_ends_on: "2026-04-05"
@client.self_assessment_returns.mark_as_filed user_id: "12345", period_ends_on: "2026-04-05"
@client.self_assessment_returns.mark_as_unfiled user_id: "12345", period_ends_on: "2026-04-05"
@client.self_assessment_returns.mark_as_paid user_id: "12345", period_ends_on: "2026-04-05"
@client.self_assessment_returns.mark_as_unpaid user_id: "12345", period_ends_on: "2026-04-05"
```

### Sales Tax Periods

US and Universal companies only.

```ruby
@client.sales_tax_periods.list
@client.sales_tax_periods.retrieve(id: "12345")
@client.sales_tax_periods.create starts_on: "2026-01-01", first_rate: "20.0"
@client.sales_tax_periods.update id: "12345", first_rate: "17.5"
@client.sales_tax_periods.delete id: "12345"
```

### CIS Bands

```ruby
@client.cis_bands.list
```

### Payroll

Organised by tax year, then by period within that year. Read-only apart from
the payment transitions.

```ruby
@client.payroll.list year: 2026
@client.payroll.retrieve year: 2026, period: 1
@client.payroll.mark_payment_as_paid year: 2026, period: 1
@client.payroll.mark_payment_as_unpaid year: 2026, period: 1
```

### Payroll Profiles

```ruby
@client.payroll_profiles.list year: 2026
@client.payroll_profiles.list year: 2026, user: "https://api.freeagent.com/v2/users/1"
```

### Properties

`UkUnincorporatedLandlord` companies only.

```ruby
@client.properties.list
@client.properties.retrieve(id: "12345")
@client.properties.create name: "12 High Street"
@client.properties.update id: "12345", name: "14 High Street"
@client.properties.delete id: "12345"
```

### Attachments

```ruby
@client.attachments.retrieve(id: "12345")
@client.attachments.delete id: "12345"
```

### Accountancy Practice API

If you've authenticated as an accountancy practice, you can list the clients
your practice has access to and make requests on their behalf. See
[the FreeAgent docs](https://dev.freeagent.com/docs/accountancy_practice_api)
for more info.

These endpoints are only available to practice-level access tokens. If each of
your users connected their own FreeAgent account via OAuth, you don't need any
of this — their token is already scoped to their company.

#### Practice details

```ruby
@client.practice.retrieve
# => #<FreeAgent::Practice name="My Practice", subdomain="mypracticesubdomain">
```

#### Clients

```ruby
@client.clients.list
@client.clients.list(view: "active")
@client.clients.list(sort: "-created_at")
@client.clients.list(updated_since: "2026-01-01T00:00:00Z")

# Fetch only the id, name and subdomain, up to 500 per page
@client.clients.list(minimal_data: true, per_page: 500)
```

`view` accepts `all`, `active`, `inactive`, `closed`, `practice`, `linked`,
`copilot` and `demo`. `sort` accepts `created_at` and `updated_at`, prefixed
with `-` for descending order. `from_date` and `to_date` are also supported.

#### Account managers

```ruby
@client.account_managers.list
@client.account_managers.retrieve(id: "123")
```

#### Making requests on behalf of a client

Requests are scoped to one of your clients by sending its subdomain in the
`X-Subdomain` header. Set it when building the client:

```ruby
@client = FreeAgent::Client.new(access_token: "", subdomain: "testcompany")

# Every request is now made against that client's account
@client.invoices.list
@client.contacts.list
```

Or derive a scoped client from your practice-level one, which is handy when
iterating over several clients:

```ruby
@practice = FreeAgent::Client.new(access_token: "")

@practice.clients.list(minimal_data: true).each do |client|
  @practice.on_behalf_of(client.subdomain).invoices.list
end
```

`on_behalf_of` returns a new client and leaves the original untouched, so the
practice-level client can still be used for `clients`, `account_managers` and
`practice`.
