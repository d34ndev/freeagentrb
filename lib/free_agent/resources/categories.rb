module FreeAgent
  class CategoriesResource < Resource
    def list(**params)
      response = get_request("categories", params: params)

      responses = []

      response.body.keys.each do |key|
        response.body[key].each do |value|
          value["category_type"] = key
          responses << Category.new(value)
        end
      end

      responses
    end

    def retrieve(nominal_code:)
      response = get_request("categories/#{nominal_code}")
      category_from(response.body)
    end

    # category_group is one of income, cost_of_sales, admin_expenses,
    # current_assets, liabilities or equities
    def create(description:, nominal_code:, category_group:, **params)
      attributes = { description: description, nominal_code: nominal_code, category_group: category_group }

      response = post_request("categories", body: { category: attributes.merge(params) })
      category_from(response.body) if response.success?
    end

    def update(nominal_code:, **params)
      response = put_request("categories/#{nominal_code}", body: { category: params })
      category_from(response.body) if response.success?
    end

    def delete(nominal_code:)
      response = delete_request("categories/#{nominal_code}")
      response.success?
    end

    private

    # A single category is returned under the type it belongs to, e.g.
    # { "income_categories" => { ... } }
    def category_from(body)
      category_type, attributes = body.first
      Category.new(attributes.merge("category_type" => category_type))
    end
  end
end
