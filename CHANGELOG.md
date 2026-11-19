# Changelog

## 1.0.0

FreeAgentRB now covers the whole FreeAgent v2 API. See
[MISSING_ENDPOINTS.md](MISSING_ENDPOINTS.md) for the one remaining gap.

### Upgrading from 0.1.x

- **Ruby 3.3 or later is required.**
- **Faraday 2.14.3 or later is required**, to avoid known security advisories.
- **Responses are `FreeAgent::Object` rather than `OpenStruct`.** Dot access,
  `[]` with a string or symbol, `to_h`, `dig`, `each_pair` and `nil` for
  unknown attributes all work as before. Code that checks
  `is_a?(OpenStruct)` or uses OpenStruct-only methods such as `delete_field`
  needs updating.
- **Monetary attributes on bills, credit notes and estimates are floats** rather
  than strings, matching invoices. Expenses work the same way.
- **`credit_notes.mark_as_cancelled` has been removed**, as FreeAgent no longer
  supports it.
- Create and update requests are now wrapped in the root element the docs
  describe (e.g. `{ contact: { ... } }`), so pass attributes directly. If you
  wrapped them yourself to work around the old behaviour, remove the wrapping.

### Added

- Expenses
- Recurring invoices, price list items, credit note reconciliations and stock
  items
- Journal sets, transactions, notes, bank feeds, email addresses and account
  locks
- Capital assets, capital asset types and hire purchases
- Balance sheet, profit and loss, trial balance, cashflow and final accounts
  reports
- VAT, corporation tax and self assessment returns, sales tax periods, CIS bands
  and CIS settings
- Payroll, payroll profiles and properties
- The accountancy practice API: practice, clients and account managers,
  including the current account manager
- `subdomain:` on `Client`, and `Client#on_behalf_of`, to act on behalf of a
  practice client
- `api_version:` on `Client`, sent as the `X-Api-Version` header
- `logger:` on `Client`
- `Client#rate_limiter`, which tracks FreeAgent's `Retry-After` after a 429 and
  can wait it out with `wait_if_rate_limited`
- `enable_rate_limit_test:` on `Client`, to test rate limiting in the sandbox
- Categories: retrieve, create, update and delete
- Company: business categories and tax timeline
- Invoices: timeline and default additional text
- Estimates: duplicate, convert to invoice and default additional text
- Timeslips: create several at once, and start and stop timers
- Bank transaction explanations: update, and list, add, update and delete
  attachments
- `bank_accounts.list` accepts any query parameters, and `bank_accounts.create`
  defaults `type:` to `StandardBankAccount`

### Fixed

- Methods that received a 204 No Content response raised `NoMethodError`
- IDs were missing for single-digit URLs, and nested URLs got the parent's ID
- `estimates.mark_as_sent` and `mark_as_draft` requested the wrong URL
- Upload requests could share the JSON connection and lose their headers
- Errors without a response body, or with a non-JSON body, now raise with a
  readable message
- Bank statement uploads are sent as `application/octet-stream`
