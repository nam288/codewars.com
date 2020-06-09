NUMBER_LITERALS = (('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a).map { |e| "'" + e + "'" } + (-100..300).to_a

COMMENT_PREFIX          = /\/\/|--|#/
COMMENT                 = /#{COMMENT_PREFIX}[^"\n]*$/
TAB                     = /\t/
CHAR_ELEMENT            = /[^\,\"\\]|\\\\|\\'|\\"|\\n|\\r|\\t/
CHAR_QUOTE              = /'/
CHAR                    = /#{CHAR_QUOTE}#{CHAR_ELEMENT}#{CHAR_QUOTE}/
NUMBER                  = /-\d+|\d+|#{CHAR}/
WHOLE_NUMBER            = /^#{NUMBER}$/
STRING_QUOTE            = /"/
STRING                  = /"#{CHAR_ELEMENT}*"/
SPACE                   = /\s/
OPEN_SQUARE             = /\[/
CLOSE_SQUARE            = /\]/

VAR_PREFIX              = /\$|_|[a-zA-Z]/
VAR_SUFFIX              = /#{VAR_PREFIX}|\d/
VAR_NAME                = /#{VAR_PREFIX}#{VAR_SUFFIX}*/
MATCH_VAR_NAME          = /^#{VAR_NAME}$/
VAR_NAME_OR_NUMBER      = /#{VAR_NAME}|#{NUMBER}/
VAR_NAME_OR_STRING      = /#{VAR_NAME}|#{STRING}/

BASIC_INSTRUCTION       = ['set', 'inc', 'dec', 'add', 'sub', 'mul', 'divmod', 'div', 'mod', 'cmp', 'a2b', 'b2a']
LIST_INSTRUCTION        = ['lset','lget']
CONTROL_INSTRUCTION     = ['ifeq','ifneq','wneq','proc','end']
CALL_INSTRUCTION        = ['call']
INTERACTIVE_INSTRUCTION = ['msg', 'read']

INSTRUCTION = /var|set|inc|dec|add|sub|mul|divmod|div|mod|cmp|a2b|b2a|lset|lget|ifeq|ifneq|wneq|proc|end|call|read|msg|rem/


EOL                     = "\n"
EOF                     = "#END#"
WORD                    = /[^ \n\[\]]+/
TOKEN                   = Regexp.union(COMMENT, TAB, NUMBER, VAR_NAME, CHAR_ELEMENT, STRING_QUOTE, SPACE, INSTRUCTION, OPEN_SQUARE, CLOSE_SQUARE, WORD, NUMBER, EOL, EOF)

BRAIN_FUCK_CHAR         = "<>+-[],.".split('')

NUMBER_COMPONENT_INS  = {
  'set'     => [1, 1, true  ],
  'inc'     => [1, 1, true  ],
  'dec'     => [1, 1, true  ],
  'add'     => [1, 2, false ],
  'sub'     => [1, 2, false ],
  'mul'     => [1, 2, false ],
  'div'     => [1, 2, false ],
  'mod'     => [1, 2, false ],
  'cmp'     => [1, 2, false ],
  'divmod'  => [2, 2, false ],
  'a2b'     => [1, 3, false ],
  'b2a'     => [3, 1, false ],
  'ifeq'    => [1, 1, true  ],
  'ifneq'   => [1, 1, true  ],
  'wneq'    => [1, 1, true  ]
}
$code = ''
$pointer = 0
$proc_tokens = []
$stack_ins = []
$string_mode = false
$var = {}
$procs = {}
$stack_context  = ['main']

class ParsingError < StandardError; end

class ExpectedEndOfLine           < ParsingError; end
class ExpectedIndex               < ParsingError; end
class ExpectedListName            < ParsingError; end
class ExpectedNumber              < ParsingError; end
class ExpectedVar                 < ParsingError; end
class ExpectedVariableInstance    < ParsingError; end
class ExpectedVarOrNumber         < ParsingError; end
class ExpectedVarSingle           < ParsingError; end
class InvalidNumberLiterals       < ParsingError; end
class InvalidVarName              < ParsingError; end
class MismatchedParenthesesError  < ParsingError; end
class MismatchedStringQuoteError  < ParsingError; end
class MismatchedCharQuoteError    < ParsingError; end
class MismatchNumberArgument      < ParsingError; end
class MissingArgument             < ParsingError; end
class NestedProcedure             < ParsingError; end
class UnclosedBlock               < ParsingError; end
class UnexpectedEndInstruction    < ParsingError; end
class UnexpectedEndOfLine         < ParsingError; end
class UnexpectedList              < ParsingError; end
class UnexpectedNumber            < ParsingError; end
class UnexpectedVar               < ParsingError; end
class UnexpectedParenthese        < ParsingError; end
class UnknownInstruction          < ParsingError; end
class DuplicateArgumentName       < ParsingError; end
class UndefinedProcedure          < ParsingError; end
class RecursiveCalling            < ParsingError; end
class DefineVariableInsideProc    < ParsingError; end
class CollapseArgument            < StandardError; end
class DeleteUntempVariable        < StandardError; end
class DuplicateVariableError      < StandardError; end
class DuplicateProcError          < StandardError; end
class InvalidTypeArgument         < StandardError; end
class NotEnoughSpaceForVariable   < StandardError; end
class OutOfRangeList              < StandardError; end
class UndefinedVariableError      < StandardError; end
class UnexpectedIndex             < StandardError; end
class UnmatchNumberArgument       < StandardError; end


def random
  NUMBER_LITERALS.sample
end

def truth_value val
  val =~ CHAR ? val[1].ord : val.to_i % 256
end

class String
  def add
    $code += self
  end
end

class Integer
  def _v
    self
  end

  def wrap
    self % 256
  end
end

class Array
  def shift_space
    while $string_mode == false and first == " "
      shift
    end
    shift
  end

  def first_space
    while $string_mode == false and self.first == " "
      shift
    end
    first
  end
end

class Variable
  @@count = 0
  @@memory = Array.new (300) { nil }
  attr_accessor :_name, :length, :type, :_address, :space, :data, :index1, :index2

  def initialize(raw: nil, at: nil, length: 1, tokens: nil)
    raise NotEnoughSpaceForVariable if at.nil? == false and @@memory[at,length].any?
    if raw.nil? or (raw.is_a? Integer)
      @_address = at ? at : self.class.emptyIndex(length)
      @_name = "temp_#{_address}"
      @@count += 1
      $var[@_name] = @@memory[@_address] = self
      @length, @type = nil, :single_var
      _set(self, raw) if (raw.is_a? Integer)
      return self
    end

    @_name, @length, @type, @_address = raw, 1, :single_var, at.nil? ? self.class.emptyIndex : at

    raise DuplicateVariableError, "Already has variable name: #{@_name}" if ($var.has_key? @_name)

    $var[@_name] = self
    @@memory[@_address] = self
    @@count += 1

    try_parse_list tokens if tokens
    self
  end

  def try_parse_list tokens
    return unless tokens.first_space =~ OPEN_SQUARE
    tokens.shift_space
    raise ExpectedNumber unless tokens.first_space =~ WHOLE_NUMBER
    @length = get_var_or_number tokens
    @@memory[@_address] = nil
    @_address = Variable.emptyIndex(@length + 4)
    @type = :list_var
    @space  = Variable.new(raw: "#{@_name}__space",   at: @_address)
    @index1 = Variable.new(raw: "#{@_name}__index1",  at: @_address + 1)
    @index2 = Variable.new(raw: "#{@_name}__index2",  at: @_address + 2)
    @data   = Variable.new(raw: "#{@_name}__data",    at: @_address + 3)
    @@memory[@_address + 4, @length] = Array.new(@length) { |i| Variable.new(raw: "#{@_name}__#{i}") }
    raise MismatchedParenthesesError unless tokens.shift_space =~ CLOSE_SQUARE
  end

  def self.emptyIndex(length = 1)
    @@memory.each_cons(length).find_index {|slice| slice.none?}
  end

  def address(index = nil)
    if type == :list_var
      raise ExpectedNumber if (index.is_a? (Integer)) == false
      raise OutOfRangeList unless (0...length) === index
      _address + index
    else
      raise UnexpectedIndex if index.nil? == false
      _address
    end
  end

  def self.count
    @@count
  end

  def self.memory
    @@memory
  end

  def self.clear
    @@count = 0
    @@memory = Array.new(300) { nil }
  end

  def delete
    return unless _name.start_with? "temp_"
    @@count -= 1
    @@memory[address] = nil
    $var.tap { |hs| hs.delete(_name) }
    _zero(self)
  end

  def value other
    _copy(other, self)
    self
  end
end

def printMemory
  (0..9).each {|i|
    print "[" + i.to_s.rjust(2,'0').center(9, ' ') + " ]"
  }
  print "\n"
  (0..9).each {|i|
    print "[" + (Variable.memory[i] ?  Variable.memory[i]._name.to_s.center(9, ' ') : " ".center(9,' ') ) + " ]"
  }
  print "\n"
end

def _to s
  raise InvalidTypeArgument unless s.is_a? Variable
  d = ($pointer - s.address).abs
  ($pointer > s.address ? '<' * d : $pointer < s.address ? '>' * d : '').add
  $pointer = s.address
end

def _to_address add
  d = ($pointer - add).abs
  ($pointer > add ? '<' * d : $pointer < add ? '>' * d : '').add
  $pointer = add
end

def _zero s
  raise InvalidTypeArgument unless s.is_a? Variable
  _to(s)
  "[-]".add
end

def _for s
  raise InvalidTypeArgument unless s.is_a? Variable
  _to(s)
  "[".add
end

def _next a
  raise InvalidTypeArgument unless a.is_a? Variable
  _to(a)
  "-]".add
end

def _move(from, to, zero_to = true)
  raise InvalidTypeArgument unless (from.is_a? Variable) and (to.is_a? Variable)
  return if from === to

  _zero(to) if zero_to
  _for(from)
  _to(to); "+".add
  _next(from)
end

def _move2(from, to1, to2)
  raise InvalidTypeArgument unless from.is_a? Variable
  raise InvalidTypeArgument unless to1.is_a? Variable
  raise InvalidTypeArgument unless to2.is_a? Variable
  return if from === to1 or from === to2 or to1 === to2

  _zero(to1)
  _zero(to2)
  _for(from)
  _to(to1); '+'.add
  _to(to2); '+'.add
  _next(from)
end

def _copy(from, to)
  raise InvalidTypeArgument unless to.is_a? Variable
  raise InvalidTypeArgument unless (from.is_a? Variable) or (from.is_a? Integer)
  return if from === to

  if (from.is_a? Integer)

    _from = Variable.new
    _to(_from)
    $code += from > 0 ? '+' * from : '-' * from.abs
    res = _copy(_from, to)
    _from.delete

    return
  end

  temp = Variable.new
  _move2(from, to, temp)
  _move(temp, from)
  temp.delete
end

def _set(res, value)
  _copy(value, res)
end

def _inc_dec(res, val, op)
  raise InvalidTypeArgument if (op.nil?) and (op != '+') and (op != '-')
  _res  = Variable.new.value(res)
  _val  = Variable.new.value(val)

  _for(_val)
  _to(_res); op.add;
  _next(_val)

  _set(res, _res)

  [_res, _val].each {|e| e.delete}
end

def _inc(res, val = 1)
  _inc_dec(res, val, '+')
end

def _dec(res, val = 1)
  _inc_dec(res, val, '-')
end

def _add_sub(res, a, b, op = nil)
  _res = Variable.new

  _set(_res, a)
  _inc_dec(_res, b, op)
  _set(res, _res)

  _res.delete
end

def _add(res, a, b)
  _add_sub(res, a, b, '+')
end

def _sub(res, a, b)
  _add_sub(res, a, b, '-')
end

def _mul(res, a, b)
  _a, _b, _res = Variable.new.value(a), Variable.new.value(b), Variable.new

  _for(_a)
  _inc(_res, _b)
  _next(_a)
  _set(res, _res)
  [_a, _b, _res].each {|e| e.delete}
end

def _divmod(div, mod, num, denom)
  one, isOne, greaterThanOne = Variable.new.value(1), Variable.new, Variable.new

  _equal(isOne, denom, one)
  _greater(greaterThanOne, denom, one)

  _if(isOne)
  _set(div, num)
  _set(mod, 0)
  _endif(isOne)

  x1 = Variable.new(length: 5).value(num)
  x2 = Variable.new(at: x1.address + 1).value(0)
  x3 = Variable.new(at: x1.address + 2).value(denom)
  x4 = Variable.new(at: x1.address + 3).value(0)
  x5 = Variable.new(at: x1.address + 4).value(0)

  _if(greaterThanOne)
  _to(x1)
  "[->+>-[>+>>]>[+[-<+>]>+>>]<<<<<<]".add
  _set(div, x5)
  _set(mod, x4)
  _endif(greaterThanOne)

  [x1, x2, x3, x4, x5, one, isOne, greaterThanOne].each {|e| e.delete}
end

def _div_or_mod(res, num, denom, calc_div)
  temp0, temp1 = Variable.new, Variable.new

  _divmod(temp0, temp1, num, denom)
  _set(res, (calc_div ? temp0 : temp1))

  [temp0, temp1].each {|e| e.delete}
end

def _div(res, num, denom)
  _div_or_mod(res, num, denom, true)
end

def _mod(res, num, denom)
  _div_or_mod(res, num, denom, false)
end

def _if a
  _to(a); '['.add
end

def _endif a
  _zero(a); ']'.add
end

def _or(res, a, b)
  _add(res, a, b)
end

def _and(res, a, b)
  _a, _b, _res = Variable.new.value(a), Variable.new.value(b), Variable.new

  _if(_a)
  _move(_b, _res)
  _endif(_a)
  _set(res, _res)

  [_a, _b, _res].each { |e| e.delete }
end

def _subtract_minimum(a, b, na, nb)
  _set(na, a); _set(nb, b)
  t1, t2, t3 = Variable.new, Variable.new, Variable.new

  _set(t1, na); _set(t2, nb); _and(t3, t1, t2)
  _to(t3); '['.add
  _zero(t3)
  _dec(na); _dec(nb)
  _set(t1, na); _set(t2, nb); _and(t3, t1, t2)
  _to(t3); ']'.add

  [t1, t2, t3].each { |e| e.delete  }
end

def _not(res, a)
  _a = Variable.new.value(a)

  _set(res, 1)
  _if(_a)
  _dec(res)
  _endif(_a)

  _a.delete
end

def _not_equal(res, a, b)
  na, nb = Variable.new, Variable.new

  _subtract_minimum(a, b, na, nb)
  _or(res, na, nb)

  [na, nb].each {|e| e.delete}
end

def _equal(res, a, b)
  _res = Variable.new

  _not_equal(_res, a, b)
  _not(res, _res)

  _res.delete
end

def _greater(res, a, b)
  na, nb = Variable.new, Variable.new

  _subtract_minimum(a, b, na, nb)
  _move(na, res)

  [na, nb].each { |e| e.delete }
end

def _less(res, a, b)
  na, nb = Variable.new, Variable.new

  _subtract_minimum(a, b, na, nb)
  _move(nb, res)

  [na, nb].each { |e| e.delete }
end

def _cmp(res, a, b)
  _zero(res)

  greater, less = Variable.new, Variable.new

  _greater(greater, a, b)
  _less(less, a, b)

  _if(greater)
  _inc(res)
  _endif(greater)

  _if(less)
  _dec(res)
  _endif(less)

  [greater, less].each { |e| e.delete }
end

def _a2b(res, a, b, c)
  _a, _b, _c = Variable.new, Variable.new, Variable.new

  _sub(_a, a, 48)
  _mul(_a, _a, 100)

  _sub(_b, b, 48)
  _mul(_b, _b, 10)

  _sub(_c, c, 48)
  _zero(res)
  _add(res, _a, _b)
  _add(res, res, _c)
  [_a, _b, _c].each { |e| e.delete }
end

def _b2a(b, c, d, a)
  _b, _c, _d = Variable.new, Variable.new, Variable.new

  _div(_b, a, 100)
  _inc(_b, 48)

  _div(_c, a, 10)
  _mod(_c, _c, 10)
  _inc(_c, 48)

  _mod(_d, a, 10)
  _inc(_d, 48)

  _set(b,_b)
  _set(c, _c)
  _set(d, _d)

  [_b, _c, _d].each { |e| e.delete }
end

def _read a
  _to(a)
  ','.add
end

def _msg tokens
  if $string_mode == false
    a = get_var(tokens)

    raise ExpectedVar unless a.type == :single_var
    _to(a)
    '.'.add
  else

    a = tokens.shift_space.gsub(/\\n/, "\n").gsub(/\\t/, "\t")
    a.chars.each {|c|
      x = Variable.new.value(c.ord)
      _to(x)
      '.'.add
      x.delete
    }
  end
end

def get_var tokens, context = nil
  context = $stack_context.last if context.nil?
  val = tokens.shift_space.downcase
  if context == 'main'
    raise MissingArgument if val == EOL
    raise InvalidVarName, "got #{val}" unless val =~ MATCH_VAR_NAME
    raise UndefinedVariableError, "got #{val}" unless $var.has_key? val
    raise UnexpectedList if $var[val].type == :list_var
    $var[val]
  else
    pr = $procs[context]
    if pr.args.include? val
      pr.params[pr.args.index(val)]
    else
      raise InvalidVarName, "got #{val}" unless val =~ MATCH_VAR_NAME
      raise UndefinedVariableError, "got #{val}" unless $var.has_key? val
      raise UnexpectedList if $var[val].type == :list_var
      $var[val]
    end
  end
end

def get_char tokens
  tokens.shift
  raise InvalidNumberLiterals if tokens.first.size != 1
  val = tokens.shift.ord
  raise MismatchedCharQuoteError if tokens.shift != "'"
  val
end

def get_var_or_number tokens
  raise MissingArgument if tokens.first_space == EOL
  return get_char tokens if tokens.first_space == "'"
  raise ExpectedVarOrNumber, "but got #{val}" unless tokens.first_space =~ VAR_NAME_OR_NUMBER
  return truth_value(tokens.shift_space) if tokens.first_space =~ WHOLE_NUMBER
  get_var tokens
end

def get_argument(tokens, *arg)
  n_var, n_number, var_first = arg
  vars = []
  numbers = []

  if var_first
    n_var   .times {vars  <<= get_var tokens  }
    n_number.times {numbers <<= get_var_or_number tokens  }
  else
    n_number.times {numbers <<= get_var_or_number tokens  }
    n_var   .times {vars  <<= get_var tokens  }
  end
  vars + numbers
end

def get_list tokens
  val = tokens.shift_space.downcase
  raise MissingArgument if val == EOL
  raise ExpectedListName, "but got #{val}" unless val =~ MATCH_VAR_NAME
  raise UndefinedVariableError, "got #{val}" unless $var.has_key? val
  raise UnexpectedVar unless $var[val].type == :list_var
  $var[val]
end

def var_instruction tokens
  tokens.shift_space
  raise DefineVariableInsideProc if $stack_context.last != 'main'
  raise UnexpectedNumber if tokens.first_space =~ WHOLE_NUMBER
  raise InvalidVarName if tokens.first_space =~ COMMENT
  while tokens.first_space != EOL
    next tokens.shift_space if tokens.first_space =~ COMMENT or tokens.first_space =~ TAB or tokens.first_space =~ SPACE
    raise MismatchedParenthesesError if tokens.first_space =~ CLOSE_SQUARE or tokens.first_space =~ OPEN_SQUARE
    raise UnexpectedNumber, "when parsing #{tokens.first_space}" if tokens.first_space =~ WHOLE_NUMBER
    raise InvalidVarName, "got #{tokens.first_space}" unless tokens.first_space =~ MATCH_VAR_NAME
    Variable.new(raw: tokens.shift_space.downcase, tokens: tokens)
  end
  raise ExpectedEndOfLine if tokens.shift_space != EOL
end

class Procedure
  attr_accessor :name, :args, :body, :params
  def initialize(name)
    raise DuplicateProcError, "program has already proc name #{name}" if $procs.has_key? name
    @name = name
    @args = []
    @params = []
    @body = []
    $procs[name] = self
    self
  end

  def add_arg arg_name
    raise DuplicateArgumentName if @args.include? arg_name
    @args <<= arg_name
  end

  def run_proc
    raise MismatchNumberArgument unless params.size == args.size
    raise RecursiveCalling if $stack_context.include? @name
    $stack_context.push @name
    _run @body.clone
    $stack_context.pop
  end
end

def proc_instruction tokens
  tokens.shift_space
  pr = Procedure.new(tokens.shift_space.downcase)
  raise UnexpectedNumber if tokens.first_space =~ WHOLE_NUMBER
  raise InvalidVarName if tokens.first_space =~ COMMENT
  while tokens.first_space != EOL
    next tokens.shift_space if tokens.first_space =~ COMMENT or tokens.first_space =~ TAB or tokens.first_space =~ SPACE
    raise UnexpectedEndInstruction if tokens.first_space =~ CLOSE_SQUARE or tokens.first_space =~ OPEN_SQUARE
    raise UnexpectedNumber, "when parsing #{tokens.first_space}" if tokens.first_space =~ WHOLE_NUMBER
    raise InvalidVarName, "got #{tokens.first_space} #{tokens}" unless tokens.first_space =~ MATCH_VAR_NAME
    pr.add_arg tokens.shift_space.downcase
  end
  raise DefineVariableInsideProc if tokens.map(&:downcase).include? "var"
  pr.body = tokens[0...tokens.rindex {|t| t.downcase == 'end'}]
end

def basic_instruction tokens
  ins = tokens.shift_space
  args = get_argument(tokens, *NUMBER_COMPONENT_INS[ins])
  raise ExpectedEndOfLine if tokens.shift_space != EOL
  send("_#{ins}", *args)
end

def _lset(list, ind, val)
  y, z = Variable.new.value(ind), Variable.new.value(val)
  space, data, index1, index2 = list.space, list.data, list.index1, list.index2
  [space, data, index1, index2].each {|x| _zero(x)}
  eval "z[-space+data+z]space[-z+space]
        y[-space+index1+y]space[-y+space]
        y[-space+index2+y]space[-y+space]
        >[>>>[-<<<<+>>>>]<[->+<]<[->+<]<[->+<]>-]
        >>>[-]<[->+<]<
        [[-<+>]<<<[->>>>+<<<<]>>-]<<"
        .gsub(/\w+/) { |m| m == "add" ? m : "_to(#{m}); "}
        .gsub(/[\<\>\[\]\+\-]+/) { |m| "\"#{m}\".add; "}
  $pointer = space._address
  [y, z].each {|x| x.delete}
end

def _lget(list, ind, val)
  x, y, z = val, list, Variable.new.value(ind)
  space, data, index1, index2 = list.space, list.data, list.index1, list.index2
  [space, data, index1, index2].each {|e| _zero(e)}
  eval "z[-space+index1+z]space[-z+space]
        z[-space+index2+z]space[-z+space]
        >[>>>[-<<<<+>>>>]<<[->+<]<[->+<]>-]
        >>>[-<+<<+>>>]<<<[->>>+<<<]>
        [[-<+>]>[-<+>]<<<<[->>>>+<<<<]>>-]<<
        x[-]
        data[-x+data]"
        .gsub(/\w+/) { |m| m == "add" ? m : "_to(#{m}); "}
        .gsub(/[\<\>\[\]\+\-]+/) { |m| "\"#{m}\".add; "}
  $pointer = data._address
  z.delete
end

def lset_instruction tokens
  tokens.shift_space
  list = get_list tokens
  ind = get_var_or_number tokens
  val = get_var_or_number tokens
  _lset(list, ind, val)
end

def lget_instruction tokens
  tokens.shift_space
  list = get_list tokens
  ind = get_var_or_number tokens
  val = get_var tokens
  _lget(list, ind, val)
end

def rem_instruction tokens
  nil while tokens.shift_space != EOL
end

def read_instruction tokens
  tokens.shift_space
  _read get_var tokens
end

def msg_instruction tokens
  tokens.shift_space
  while tokens.first_space != EOL
    tokens.first_space
    next tokens.shift_space if tokens.first_space =~ COMMENT and $string_mode == false
    if tokens.first_space =~ STRING_QUOTE
      $string_mode = !$string_mode
      next tokens.shift_space
    end
    _msg(tokens)
  end
  raise MismatchedStringQuoteError if $string_mode
end

def _ifeq a, b
  _equal(c = Variable.new, a, b)
  _to(c); "[".add
  $stack_ins <<= [c, __method__.to_sym]
  c.delete
end

def _ifneq a, b
  _not_equal(c = Variable.new, a, b)
  _to(c); "[".add
  $stack_ins <<= [c, __method__.to_sym]
end

def _wneq a, b
  c = Variable.new
  _not_equal(c, a, b)
  _to(c); "[".add
  $stack_ins <<= [c, a, b, __method__.to_sym]
end

def _end tokens
  tokens.shift_space
  raise UnexpectedEndInstruction if $stack_ins.empty?
  val, *args, type = $stack_ins.pop
  if type == :_ifeq or type == :_ifneq
    _to(val)
    _zero(val)
  elsif type == :_wneq
    _not_equal(val,*args)
    _to(val)
  end
  "]".add
end

def call_instruction tokens
  tokens.shift_space
  pr_name = tokens.shift_space.downcase

  raise UndefinedProcedure, "got #{pr_name}" unless $procs.has_key? pr_name
  pr = $procs[pr_name]
  pr.params.clear
  while tokens.first_space != EOL
    next tokens.shift_space if tokens.first_space =~ COMMENT or tokens.first_space =~ TAB or tokens.first_space =~ SPACE
    raise InvalidVarName, "got #{tokens.first_space}" unless tokens.first_space =~ MATCH_VAR_NAME
    pr.params <<= get_var tokens
  end
  pr.run_proc
end

def control_instruciton tokens
  ins = tokens.shift_space
  return (_end tokens) if ins == 'end'
  args = get_argument(tokens, *NUMBER_COMPONENT_INS[ins])
  raise ExpectedEndOfLine if tokens.shift_space != EOL
  send("_#{ins}", *args)
end

def get_proc tokens
  proc_mode = false
  deep = 0
  will_del = []
  tokens.each.with_index {|t,i|
    if t.downcase == 'proc'
      raise NestedProcedure if proc_mode
      proc_mode = true
      $proc_tokens <<= [t]
      will_del <<= i
      deep += 1
      next
    end

    if proc_mode
      $proc_tokens.last.push t
      will_del <<= i
    end

    if t.downcase == 'end'
      deep -= 1
      raise UnexpectedEndInstruction if deep < 0
      proc_mode = false if proc_mode and deep == 0
      next
    end

    deep += 1if CONTROL_INSTRUCTION.include?(t.downcase) and t != 'call'
  }
  will_del.reverse.each {|i| tokens.delete_at(i)}
  $proc_tokens.each {|pr| proc_instruction pr}
end

def run plain_code
  $var = {}
  $pointer = 0
  $code = ''
  $procs = {}
  $proc_tokens = []
  $stack_ins = []
  $string_mode = false
  $stack_context  = ['main']

  Variable.clear
  tokens = plain_code.scan(TOKEN)
  tokens <<= EOL if tokens.last != EOL
  tokens <<= EOF
  get_proc tokens
  _run tokens
end

def _run tokens
  while tokens.first_space != EOF
    return if tokens.empty?
    tokens.first_space.downcase!
    next tokens.shift_space if tokens.first_space == EOL or tokens.first_space =~ TAB or tokens.first_space =~ COMMENT or tokens.first_space =~ SPACE
    raise UnknownInstruction, "unknown #{tokens.first_space} instruction" unless tokens.first_space =~ INSTRUCTION
    next basic_instruction tokens if BASIC_INSTRUCTION.include? tokens.first_space
    next control_instruciton tokens if CONTROL_INSTRUCTION.include? tokens.first_space
    send("#{tokens.first_space}_instruction", tokens)
  end
  raise UnclosedBlock unless $stack_ins.empty?
  $code
end

def kcuf plain_code
  run plain_code
end
