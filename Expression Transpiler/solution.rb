NAME_OR_NUMBER    = /\w+|_+/
TERM           = /^([a-zA-Z_][a-zA-Z_0-9]*|\d+)$/
OPEN_SQUARE       = "["
OPEN_CURLY        = "{"
OPEN_PARENTHESIS  = "("
CLOSE_SQUARE      = "]"
CLOSE_CURLY       = "}"
CLOSE_PARENTHESIS = ")"
ARROW             = "->"
COMMA             = ','
TOKEN = Regexp.union(NAME_OR_NUMBER, OPEN_PARENTHESIS, OPEN_CURLY, OPEN_SQUARE, CLOSE_PARENTHESIS, CLOSE_CURLY, CLOSE_SQUARE, ARROW, COMMA)

def assert condition
  raise StandardError, "#{condition}" unless condition
end

def get_term tokens
  assert tokens.first =~ TERM
  tokens.shift
end

class Lambda
  def initialize tokens
    assert tokens.shift == OPEN_CURLY
    @param = lambdaparam tokens
    @stmt = lambdastmt tokens
  end

  def lambdastmt tokens
    assert tokens.include? CLOSE_CURLY
    res = []
    res <<= get_term tokens while tokens.first != CLOSE_CURLY
    tokens.shift
    res
  end

  def lambdaparam tokens
    return [] if tokens.index(ARROW).nil? or tokens.index(ARROW) > tokens.index(CLOSE_CURLY)
    res = [get_term(tokens)]
    while tokens.first != ARROW
      assert tokens.shift == COMMA
      res <<= get_term tokens
    end
    tokens.shift
    res
  end

  def to_s
    "(#{@param.join(',')}){#{@stmt.map { |e| e + ";" }.join}}"
  end
end

def get_expression tokens
  tokens.first == OPEN_CURLY ? Lambda.new(tokens) : (get_term tokens)
end

def get_parameter tokens
  assert tokens.include? CLOSE_PARENTHESIS
  tokens.shift
  return (tokens.shift; []) if tokens.first == CLOSE_PARENTHESIS
  res = [get_expression(tokens)]
  while tokens.first != CLOSE_PARENTHESIS
    assert tokens.shift == COMMA
    res <<= get_expression tokens
  end
  tokens.shift
  res
end

class Func
  def initialize tokens
    @exp = get_expression tokens
    if tokens.first == OPEN_PARENTHESIS
      @param = get_parameter tokens
      @lambda = tokens.first == OPEN_CURLY ? Lambda.new(tokens) : nil
    else
      @param = []
      @lambda = Lambda.new tokens
    end
    assert tokens.empty?
  end

  def to_s
    "#{@exp}(#{(@param << @lambda).compact.join(',')})"
  end
end


def transpile source
  begin
    assert source.gsub(TOKEN, '').gsub(/\s/,'').empty?
    Func.new source.scan TOKEN
  rescue
    ""
  end
  .to_s
end
