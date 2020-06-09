UNARY_OPS = %w{cos sin tan exp ln}
BINARY_OPS = %w{+ - * / ^}

def _ *arg
  return Node.new(nil, *arg, nil) if arg.size == 1
  return Node.new(arg[1], arg[0], nil) if arg.size == 2
  Node.new(*arg)
end

class Node
  attr_accessor :a, :b, :op
  def initialize *arg
    @a, @op, @b = arg
  end

  def is_var?
    op == 'x'
  end

  def contain_var?
    is_var? || (a && a.contain_var?) || (b && b.contain_var?)
  end

  def is_one?
    op == '1'
  end

  def is_zero?
    op == '0'
  end

  def is_num?
    op =~ /\-?\d+/
  end

  def d
    case op
    when 'x'      then _('1')
    when /-?\d+/    then _('0')
    when '+', '-' then _(a.d, op, b.d)
    when '*'      then _(_(a.d, '*', b), '+', _(a, '*', b.d))
    when '/'      then _(_(_(a.d, '*', b), '-', _(a, '*', b.d)), '/', _(b, '^', _('2')))
    when '^'      then
      if a.contain_var?
        n = b.op.to_i
        n == 0 ? _(nil, '0', nil) : n == 1 ? a.d : _(_(n.to_s), '*', _(a, '^', _((n-1).to_s)))
      else
        _(_(_('ln', a), '*', self), '*', b.d)
      end
    when 'cos' then _(_(_('-1'), '*', a.d), '*', _('sin', a))
    when 'sin' then _(a.d, '*', _('cos', a))
    when 'tan' then _(a.d, '*', _(_('cos', a), '^', _('-2')))
    when 'exp' then _(a.d, '*', self)
    when 'ln'  then _(a.d, '/', a)
    end
  end

  def clean
    return self if is_var? || is_num?
    return _(op, a.clean) unless b
    u, v = a.clean, b.clean
    if u.is_num? && v.is_num?
      x, y = u.op.to_i, v.op.to_i
      return x % y == 0 ? _((x/y).to_s) : _((x.to_f / y).to_s) if op == '/'
      return _((op == '^' ? x **y : x.send(op, y)).to_s)
    end

    if op == '*'
      return u if v.is_one?
      return v if u.is_one?
      return _('0') if u.is_zero? || v.is_zero?
    end

    if op == "+"
      return v if u.is_zero?
      return u if v.is_zero?
    end

    if (op == "+" || op == "*") && u.is_num? && v.op == op && (v.a.is_num? || v.b.is_num?)
      return _(_(u, op, v.a).clean, op, v.b) if v.a.is_num?
      return _(_(u, op, v.b).clean, op, v.a)
    end

    if op == '^'
      return a if v.is_one?
      return _('1') if v.is_zero?
    end
    return _(u, op, v)
  end

  def prefix
    return op if is_var? or is_num?
    (BINARY_OPS.include? op) ? "(#{op} #{a.prefix} #{b.prefix})" : "(#{op} #{a.prefix})"
  end

end

def parse tokens
  if tokens.first == '('
    tokens.shift
    op = tokens.shift
    a = parse tokens
    b = parse tokens if BINARY_OPS.include? op
    tokens.shift
    return _(a, op, b)
  end
  _(tokens.shift)
end

def diff(s)
  tokens = s.scan /\w+|\-?\d+|[^ ]/
  (parse tokens).d.clean.prefix
end

p diff('(cos x)')
