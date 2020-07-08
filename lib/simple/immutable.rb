module Simple
end

class Simple::Immutable
  SELF = self

  # turns an object, which can be a hash or array of hashes, arrays, and scalars
  # into an object which you can use to access with dot methods.
  def self.create(object, max_depth = 5)
    case object
    when Array
      raise ArgumentError, "Object nested too deep (or inner loop?)" if max_depth < 0

      object.map { |obj| create obj, max_depth - 1 }
    when Hash
      new(object)
    else
      object
    end
  end

  def self.raw_data(immutable)
    case immutable
    when SELF
      immutable.instance_variable_get :@hsh
    when Array
      immutable.map { |e| raw_data(e) }
    else
      immutable
    end
  end

  private

  def initialize(hsh)
    @hsh = hsh
  end

  def method_missing(sym, *args, &block)
    if args.empty? && !block
      begin
        value = @hsh.fetch(sym.to_sym) { @hsh.fetch(sym.to_s) }
        return SELF.create(value)
      rescue KeyError
        # STDERR.puts "Missing attribute #{sym} for Immutable w/#{@hsh.inspect}"
        nil
      end
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

  def respond_to?(sym)
    super || @hsh.key?(sym.to_s) || @hsh.key?(sym.to_sym)
  end

  def ==(other)
    @hsh == other
  end
end
