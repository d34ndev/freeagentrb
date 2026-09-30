module FreeAgent
  # A lightweight wrapper around API response data. Attributes can be read with dot notation
  # (object.name) or like a hash (object[:name] or object["name"]). Nested hashes are wrapped too.
  class Object
    # Declares attributes the API sends as strings which should be exposed as
    # floats, e.g. decimal_attributes :total_value
    def self.decimal_attributes(*names)
      @decimal_attributes = names.map(&:to_s)
    end

    def self.decimal_attribute_names
      @decimal_attributes || []
    end

    def initialize(attributes = {})
      @attributes = {}
      (attributes || {}).each { |key, val| self[key] = val }

      # The FreeAgent API doesn't send an ID so generate it from the URL
      if self[:url].is_a?(String)
        number = self[:url].match(/\d{2,}/)
        self[:id] = number[0] unless number.nil?
      end

      self.class.decimal_attribute_names.each do |name|
        value = self[name]
        next if value.nil? || value.to_s.empty?

        self[name] = BigDecimal(value.to_s).to_f
      end
    end

    def [](key)
      @attributes[key.to_sym]
    end

    def []=(key, val)
      @attributes[key.to_sym] = wrap(val)
    end

    def key?(key)
      @attributes.key?(key.to_sym)
    end

    def dig(key, *rest)
      val = self[key]
      rest.empty? || val.nil? ? val : val.dig(*rest)
    end

    def each_pair(&block)
      return enum_for(:each_pair) unless block_given?

      @attributes.each_pair(&block)
      self
    end

    # Returns the attributes as a hash, with nested objects converted to hashes too,
    # so the result can be serialized
    def to_h(&block)
      hash = @attributes.transform_values { |val| unwrap(val) }
      block ? hash.to_h(&block) : hash
    end

    def as_json(*)
      to_h
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    def ==(other)
      other.is_a?(FreeAgent::Object) && to_h == other.to_h
    end
    alias eql? ==

    def hash
      to_h.hash
    end

    def inspect
      attrs = @attributes.map { |key, val| "#{key}=#{val.inspect}" }.join(", ")
      "#<#{self.class.name}#{" " unless attrs.empty?}#{attrs}>"
    end
    alias to_s inspect

    private

    # Unknown attributes return nil, like a hash
    def method_missing(name, *args)
      if name.end_with?("=") && args.size == 1
        self[name.to_s.chomp("=")] = args.first
      elsif args.empty? && !name.end_with?("=", "?", "!")
        self[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      key?(name.to_s.chomp("=")) || super
    end

    def wrap(val)
      case val
      when FreeAgent::Object then val
      when Hash then FreeAgent::Object.new(val)
      when Array then val.map { |v| wrap(v) }
      else val
      end
    end

    def unwrap(val)
      case val
      when FreeAgent::Object then val.to_h
      when Array then val.map { |v| unwrap(v) }
      else val
      end
    end
  end
end
