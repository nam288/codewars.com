const mod = (a, b) => ((a % b) + b) % b;
const fst = c => [3, c == "D" ? 3 : c == "U" ? 4 : 2];

function f(a, b, c) {
  (a *= 3), (b *= 3);
  if (c == "D") return [a, b];
  if (c == "d") {
    if ((b += 1) & 1) b += a;
    return [a, ~~(b / 2)];
  }
  m = mod((b -= 2), (c = 4));
  b = ~~((b + ((4 + (mod(a, c) - 1 ? m : -m)) % 4) * a) / 4);
  if (b == 1) b += a;
  return [a, b];
}

function freakContazSequence(s) {
  let [a, b] = fst(s[s.length - 1]);
  s.split("")
    .reverse()
    .slice(1)
    .forEach(c => ([a, b] = f(a, b, c)));
  return b;
}
