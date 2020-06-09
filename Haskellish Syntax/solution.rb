class Double < Numeric; end

$queueArgs = []
$funcWaiting = nil
$signature = {}
$functions = {}
$mode = nil

def getType e
  case e
  when String then String
  when Numeric then Double
  when Variable then e._valueType
  else raise TypeError
  end
end

class Variable

  attr_accessor :_name, :_type, :_func, :_args, :_root,
    :_index, :_pairity, :_valueType, :_value

  def initialize(name, type, *args)
    @_name, @_type = name, type
    if type == :func
      if $signature[name].first.size != args.size
        $signature.delete(name)
        $queueArgs.clear
        $functions.delete(name)
        raise ArgumentError
      end
      @_args = args.map.with_index {|arg, i|
      Variable.new(arg, :argument, i, self, $signature[name].first[i])}
      @_pairity = @_args.size
      @_valueType = $signature[name].last
      $queueArgs.clear
      $mode = :needRHS

    elsif type == :argument
      @_index, @_func, @_valueType = args

    elsif type == :binary
      l_type, r_type = args.map {|e| getType e}
      case @_name
      when ?+
        raise TypeError unless l_type == r_type
        @_valueType = l_type
      when ?*
        raise TypeError unless r_type == Double
        @_valueType = l_type
      when ?-, ?/, "**"
        raise TypeError unless l_type == Double && r_type == Double
        @_valueType = Double
      end
      @l, @r = args

    elsif type == :lambda
      if args.size != $functions[name]._pairity
        $mode = nil
        raise ArgumentError
      end
      @_args      = args
      @_valueType = $functions[name]._valueType
    elsif type == :primitive
      @_value     = args[0]
      @_valueType = getType @_value
    else
      raise NotImplementedError
    end
    self
  end

  def getArgument name
    raise TypeError if _type != :func
    _args.find {|arg| arg._name == name}
  end

  %w{+ - * / **}.map {|e|
    define_method e do |o|
      Variable.new(e, :binary, self, o)
    end
  }

  def coerce(other)
    [Variable.new(other.to_s, :primitive, other), self]
  end

  def == o
    if getType(o) != @_valueType
      $mode = nil
      raise TypeError
    end

    $mode = nil
    $funcWaiting = nil
    @_root = o
  end

  def call(*args)

    if _type == :func
      raise ArgumentError if args.size != @_args.size
      args.each.with_index {|e, i|
        valueType = @_args[i]._valueType
        raise TypeError if valueType != getType(e)
      }
    end

    case _type
    when :argument  then args[_index]
    when :func      then Variable === @_root ? @_root.call(*args) : @_root
    when :primitive then @_value
    when :binary
      l, r = [@l, @r].map { |e| Variable === e ? e.call(*args) : e}
      l.send(@_name.to_sym, r)
    when :lambda
      params = _args.map { |e| Variable === e ? e.call(*args) : e}
      $functions[_name].call(*params)
    end
  end
end

class Object
  def method_missing(m, *args, &block)
    m = m.to_s

    if m == "show"
      return case res = args.first.to_s
      when String   then  res =~ /^-?\d+$/ ? res + ".0" : res
      when Integer  then  res.to_s + ".0"
      when Float    then  res.to_s
      end
    end

    return if ["begin", "end", "exclude_end?", "to_hash"].include?(m)

    if $mode == :needRHS
      return Variable.new(m, :lambda, *args) if $functions.has_key?(m)
      return $functions[$funcWaiting].getArgument(m)
    end

    if args.empty?
      raise ArgumentError if $functions.has_key?(m)
      $queueArgs << m.to_s
      return
    end

    return $functions[m].call(*args) if Variable === $functions[m]

    return $functions[$funcWaiting = m] = Variable.new(m, type = :func, *$queueArgs) if $functions.has_key?(m)


    *args_type, return_type = args.flat_map {|e| Hash === e ? e.keys + e.values : e}
    $queueArgs.clear
    $signature[m] = [args_type, return_type]
    $functions[m] = nil
  end
end
