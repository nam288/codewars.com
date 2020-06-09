def pre(a, k)
  d = k.to_s(2).size - 1
  m = k - (1 << d)
  t = 1 << d
  n_group = a.fdiv(t).ceil
  n_heads = n_group.even? ? [n_group - 2, 0].max : n_group - 1
  last_arr, last_indices = n_group.even? ?
    [[t, a - t * (n_group - 1)], [n_heads, n_heads + 1]] :
    [[a - t * n_heads, nil], [n_heads, nil]]
  get_cnt = ->(i) { i ? i < n_heads ? t : i == n_heads ? last_arr.first : i == n_heads + 1 ? last_arr.last : nil : nil }
  { n_group: n_group, last_arr: last_arr, n_heads: n_heads, last_indices: last_indices, get_cnt: get_cnt }
end

def f2(a, k)
  return $h_f2[[a, k]] if $h_f2[[a, k]]
  return a.min if k == 0

  a.sort!
  d = k.to_s(2).size - 1
  m = k - (1 << d)
  t = 1 << d
  configs = a.map { |e| pre(e, k) }

  g = lambda { |x|
    n = configs.map { |e| e[:get_cnt].call(x) }
    n.all? ? n.reduce(:*) % $MOD : 0
  }
  g2 = lambda { |x|
    return 0 unless x && (y = x ^ 1)

    n = configs.zip([x, y]).map { |e, i| e[:get_cnt].call(i) }
    n.all? ? f2(n, m) : 0
  }

  $h_f2[[a, k]] = (configs[0][:n_heads] * (t**2 % $MOD + f2([t, t], m)) % $MOD +
                   configs[0][:last_indices].map { |i| (g.call(i) + g2.call(i)) % $MOD }.sum % $MOD) % $MOD
end

def sum_xor_all_pair(d)
  # return sum of xor all pair in range 0...1<<d
  x = (1 << (d - 1)) % $MOD
  y = x * x % $MOD
  y * ((x << 2) % $MOD - 2) % $MOD
end

def cnt_bit_pos(n)
  res = Hash.new 0
  m = n.to_s(2).chars.map(&:to_i)
  sz = m.size
  m.each_with_index do |e, i|
    next if e.zero?
    d = sz - i - 1
    shift_d_1 = 1 << (d - 1)
    shift_d = shift_d_1 << 1
    unless d.zero?
      (0..d - 1).each { |j| res[j << 1] += shift_d_1; res[(j << 1) + 1] += shift_d_1 }
      res[d << 1] += shift_d - 1
    end
    res[(d << 1) + 1] += 1
    m[0...i].each_with_index { |ee, ii| res[ee + ((sz - ii - 1) << 1)] += 1 << d }
  end
  (0...sz).each { |i| res[i << 1] += 1 }
  res
end

def sum_xor_all_pair2(a)
  # return sum of xor all pair in range (0..a.first) and (0..a.last)
  a.sort!
  cnts = a.map { |e| cnt_bit_pos e }
  res = 0
  cnts.last.each_pair do |k, v|
    pos, bit = k.divmod(2)
    k2 = (pos << 1) + 1 - bit
    v2 = cnts.first[k2].zero? && bit == 1 ? a.first + 1 : cnts.first[k2]
    res = (res + v * v2 * (1 << pos) % $MOD) % $MOD
  end
  res
end

def f3(a, k)
  return $h_f3[[a, k]] if $h_f3[[a, k]]
  return 0 if k.zero?
  a.sort!
  d = k.to_s(2).size - 1
  m = k - (1 << d)
  t = 1 << d
  configs = a.map { |e| pre(e, k) }

  g = lambda { |x|
    n = configs.map { |e| (r = e[:get_cnt].call(x)) ? r - 1 : nil }
    n.all? ? sum_xor_all_pair2(n) : 0
  }
  g2 = lambda { |x|
    return 0 unless x && (y = x ^ 1)
    n = configs.zip([x, y]).map { |e, i| e[:get_cnt].call(i) }
    n.all? ? f2(n, m) * t + f3(n, m) : 0
  }
  x1 = configs[0][:n_heads] * sum_xor_all_pair(d) % $MOD
  x2 = configs[0][:last_indices].map { |i| g.call(i) }.sum % $MOD
  x3 = configs[0][:n_heads] * (f3([t, t], m) + f2([t, t], m) * t % $MOD) % $MOD
  x4 = configs[0][:last_indices].map { |i| g2.call(i) }.sum % $MOD
  $h_f3[[a, k]] = (x1 + x2 + x3 + x4) % $MOD
end

def elder_age(m, n, l, t)
  $h_f2 = {}
  $h_f3 = {}
  $MOD = t
  (((sum_xor_all_pair2([m - 1, n - 1]) - f3([m, n], l)) % $MOD) - (l * (m * n % $MOD - f2([m, n], l)) % $MOD)) % $MOD
end
