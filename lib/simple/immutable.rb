module Simple
end

class Simple::Immutable
  SELF = self

  # turns an object, which can be a hash or array of hashes, arrays, and scalars
  # into an object which you can use to access with dot methods.
  def self.create(object, max_depth: 8, null_record: nil)
    case object
    when Array
      raise ArgumentError, "Object nested too deep (or inner loop?)" if max_depth < 0

      object.map { |obj| create obj, null_record: null_record, max_depth: max_depth - 1 }
    when Hash
      new(object, null_record)
    else
      object
    end
  end

  def self.raw_data(immutable)
    case immutable
    when SELF
      hsh = immutable.instance_variable_get :@hsh
      null_record = immutable.instance_variable_get :@null_record

      if null_record
        null_record.merge(hsh)
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

  def initialize(hsh, null_record = nil)
    @hsh = hsh
    @null_record = null_record
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
    if args.empty? && !block
      value = SELF.fetch_symbol_or_string_from_hash(@hsh, sym) do
        SELF.fetch_symbol_or_string_from_hash(@null_record, sym) do
          # STDERR.puts "Missing attribute #{sym} for Immutable w/#{@hsh.inspect}"
          super
        end
      end

      return SELF.create(value)
    end

    super
  end

  public

  def inspect
    "<#{self.class.name}: #{@hsh.inspect}>"
  end

  def respond_to_missing?(method_name, include_private = false)
    @hsh.key?(method_name.to_sym) ||
      @hsh.key?(method_name.to_s) ||
      super
  end

  def respond_to?(sym, include_all = false)
    super || @hsh.key?(sym.to_s) || @hsh.key?(sym.to_sym)
  end

  def ==(other)
    @hsh == other
  end
end
