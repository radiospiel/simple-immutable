module Simple
end

class Simple::Immutable
  SELF = self

  # turns an object, which can be a hash or array of hashes, arrays, and scalars
  # into an object which you can use to access with dot methods.
  def self.create(object, max_depth: 8, null_record: nil, fallback: nil)
    # Note that null_record is deprecated.
    fallback ||= null_record

    case object
    when Array
      raise ArgumentError, "Object nested too deep (or inner loop?)" if max_depth < 0

      object.map { |obj| create obj, fallback: fallback, max_depth: max_depth - 1 }
    when Hash
      new(object, fallback)
    else
      object
    end
  end

  def self.raw_data(immutable)
    case immutable
    when SELF
      hsh = immutable.instance_variable_get :@hsh
      fallback = immutable.instance_variable_get :@fallback

      if fallback
        fallback.merge(hsh)
      else
        hsh
      end
    when Array
      immutable.map { |e| raw_data(e) }
    else
      immutable
    end
  end

  # adds to_json support.
  def as_json(opts)
    @hsh.as_json(opts)
  end

  private

  def initialize(hsh, fallback = nil)
    @hsh = hsh
    @fallback = fallback
  end

  # rubycop:disable Lint/IneffectiveAccessModifier

  # fetches key from a hsh, regardless of it being a Symbol or a String.
  # Yields the block if the key cannot be found.
  def self.fetch_symbol_or_string_from_hash(hsh, key, &block)
    if hsh
      hsh.fetch(key.to_sym) do
        hsh.fetch(key.to_s, &block)
      end
    else
      yield
    end
  end

  def method_missing(sym, *args, &block)
    raise ArgumentError, "Immutable: called attribute method with arguments" unless args.empty?
    raise ArgumentError, "Immutable: called attribute method with arguments" if block

    # If the symbol ends in "?" we do not raise a NameError, but return nil
    # if the attribute is not known.
    check_mode = sym.end_with?("?")
    if check_mode
      # Note that sym is now a String. However, we are String/Symbol agnostic
      # (in fetch_symbol_or_string_from_hash), so this is ok.
      sym = sym[0...-1]
    end

    value = SELF.fetch_symbol_or_string_from_hash(@hsh, sym) do
      SELF.fetch_symbol_or_string_from_hash(@fallback, sym) do
        raise NameError, "unknown immutable attribute '#{sym}'" unless check_mode

        nil
      end
    end

    SELF.create(value)
  end

  public

  def inspect
    "<#{self.class.name}: #{@hsh.inspect}>"
  end

  def respond_to_missing?(method_name, include_private = false)
    return true if method_name.end_with?("?")

    key = method_name.to_sym
    return true if @hsh.key?(key)
    return true if @fallback&.key?(key)

    key = method_name.to_s
    return true if @hsh.key?(key)
    return true if @fallback&.key?(key)

    super
  end

  # rubocop:disable Style/OptionalBooleanParameter
  def respond_to?(sym, include_all = false)
    super || @hsh.key?(sym.to_s) || @hsh.key?(sym.to_sym)
  end

  def ==(other)
    @hsh == other
  end
end
