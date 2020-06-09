const d = (s, n, i) => (i + n < 0 ? 0 : +s[n + i]);
const rm = s => s.replace(/^0+/, "");
const sgn = s => (/^-/.exec(s) ? -1 : s == "0" ? 0 : 1);
const abs = s => s.replace(/^-/, "");
const inv = s => (sgn(s) == 0 ? s : sgn(s) < 0 ? s.slice(1) : "-" + s);

function cmp(a, b) {
  let [sa, sb] = [a.length, b.length];
  if (sa != sb) return sa < sb ? -1 : 1;
  for (let i = 0; i < sa; i++) if (a[i] != b[i]) return +a[i] < +b[i] ? -1 : 1;
  return 0;
}

function add(a, b) {
  let [sa, sb, i, c, s] = [a.length, b.length, 0, 0, ""];
  while (--i + sa >= 0 || i + sb >= 0) {
    c += d(a, sa, i) + d(b, sb, i);
    s = (c % 10) + s;
    c = ~~(c / 10);
  }
  return rm(c + s);
}
function subtract(a, b) {
  let [sa, sb, i, c, s] = [a.length, b.length, 0, 0, ""];
  while (--i + sa >= 0 || i + sb >= 0) {
    c = d(a, sa, i) - d(b, sb, i) - (c < 0);
    s = ((c + 10) % 10) + s;
  }
  return rm(s);
}

function _mul(a, b) {
  let n = a.length,
    c = 0,
    s = "",
    i;
  for (i = n - 1; i + 1; i--) {
    c += a[i] * b;
    s = (c % 10) + s;
    c = ~~(c / 10);
  }
  return c + s;
}

function multiply(a, b) {
  let [n, s, m, i] = [b.length, "", ""];
  for (i = n - 1; i + 1; m += "0") s = add(s, _mul(a, +b[i--]) + m);
  return rm(s);
}

function _divide(a, b) {
  for (let i = 9, t; i + 1; i--)
    if (cmp(multiply(b, "" + i), a) <= 0) return "" + i;
}

function divide(a, b) {
  let [n, r, q, i, t] = [a.length, "0", "0", 0, ""];
  while (i < n) {
    t = rm(subtract(t, multiply(b, q)) + a[i++]);
    r += q = _divide(t, b);
  }
  return rm(r);
}

function bigSub(a, b) {
  [a, b] = [rm("" + a), rm("" + b)];
  if (sgn(a) < 0) return inv(bigSub(inv(a), inv(b)));
  if (sgn(a) == 0) return inv(b);
  if (sgn(b) < 0) return add(a, abs(b));
  if (sgn(b) == 0) return a;
  return cmp(a, b) == 0
    ? "0"
    : cmp(a, b) > 0
    ? subtract(a, b)
    : inv(subtract(b, a));
}

function bigAdd(a, b) {
  [a, b] = [rm("" + a), rm("" + b)];
  return sgn(a) < 0
    ? inv(bigAdd(inv(a), inv(b)))
    : sgn(b) < 0
    ? bigSub(a, inv(b))
    : add(a, b);
}

function integerSquareRoot(n) {
  let x = n.slice(0, n.length / 2),
    y,
    z;
  while (1) {
    y = divide(bigAdd(x, divide(n, x)), "2");
    if (cmp(abs(bigSub(x, y)), "1") <= 0) return y;
    x = y;
  }
}
