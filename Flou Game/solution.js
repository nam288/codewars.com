const sz = a => a.length;
const DIR = [
  [0, 1],
  [1, 0],
  [0, -1],
  [-1, 0]
];
const inRange = (x, l, r) => l <= x && x <= r;

var a, f, r, c, path, b;

function parse(s) {
  for (let i = 1, j; i < r + 1; i++) {
    f[i - 1] = [];
    for (j = 1; j < c + 1; j++)
      if (s[i][j] == "B") a.push([i - 1, j - 1]), f[i - 1].push(1);
      else f[i - 1].push(0);
  }
}

function fill(x1, y1, x2, y2, dx, dy, v) {
  while (x1 - x2 || y1 - y2) {
    f[x1][y1] = v;
    (x1 += dx), (y1 += dy);
  }
  f[x2][y2] = v;
}

function spread(d, cnt, i, x, y) {
  const valid = (x, y) =>
    inRange(x, 0, r - 1) && inRange(y, 0, c - 1) && f[x][y] == 0;
  if (d == -1) {
    if (b.every(e => e)) return !cnt && sz(path) == sz(a);

    for (i = 0; i < sz(b); i++) {
      if (b[i]) continue;
      for (d = 0; d < 4; d++) {
        if (!valid(a[i][0] + DIR[d][0], a[i][1] + DIR[d][1])) continue;
        b[i] = 1;
        path.push([i, d]);
        if (spread(d, cnt, i, ...a[i])) return true;
        path.pop();
        b[i] = 0;
      }
    }
    return false;
  }
  let [dx, dy] = DIR[d];

  let [x1, y1] = [x + dx, y + dy];
  if (!valid(x1, y1)) return spread(-1, cnt);

  let [x2, y2] = [x1, y1];
  while (valid(x2, y2)) (x2 += dx), (y2 += dy);
  (x2 -= dx), (y2 -= dy);

  fill(x1, y1, x2, y2, dx, dy, 1);
  if (
    spread(
      (d + 1) % 4,
      cnt - Math.abs(d & 1 ? x2 - x1 : y2 - y1) - 1,
      i,
      x2,
      y2
    )
  )
    return true;
  fill(x1, y1, x2, y2, dx, dy, 0);
  return false;
}

function playFlou(gameMap) {
  s = gameMap.split("\n");
  [r, c, a, b, path, f] = [sz(s) - 2, sz(s[0]) - 2, [], [], [], []];
  parse(s);
  b = Array.from(a, _ => 0);
  if (spread(-1, r * c - sz(a)) && sz(path) == sz(a))
    return path.map(e => [...a[e[0]], ["Right", "Down", "Left", "Up"][e[1]]]);
  return false;
}
