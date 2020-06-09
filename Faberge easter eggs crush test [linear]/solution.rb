# MOD = 998_244_353
MAX_N = 100_005
$h_inv_mod = {}


def pow_mod(x, y, m = MOD)
  return 1 if x == 1
  return x % m if y == 1
  return x * pow_mod(x, y - 1, m) % m if y.odd?
  x = pow_mod(x, y >> 1, m)
  x ** 2 % m
end

def inv_mod(x, m = MOD)
  return $h_inv_mod[x] if $h_inv_mod[x]
  $h_inv_mod[x] = pow_mod(x, m - 2, m)
end

def sum_c(n, k, m)
  s = x = n % m
  t = (n + 1) % m
  (2..k).each do |i|
    x = x * (t - i) % m * inv_mod(i, m) % m
    s = (s + x) % m
  end
  s
end

$fact = Array.new(MAX_N, 1)
(2..MAX_N-1).each {|i| $fact[i] = $fact[i-1] * i % MOD}
$inv_fact = $fact.map {|i| inv_mod(i, MOD)}

def sum_c_case_2(n, k, m)
  s = 0
  (1..k).each do |i|
    s = (s + ($inv_fact[i] * $inv_fact[n-i] % MOD)) % MOD
  end
  $fact[n] * s % MOD
end

def height(n,m)
  n > m ? (pow_mod(2,m) - 1) % MOD : m <= 100_000 ? sum_c_case_2(m,n,MOD) : sum_c(m,n, MOD)
end
