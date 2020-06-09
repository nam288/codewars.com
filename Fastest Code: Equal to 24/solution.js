var values,
  exps = [],
  shorten = [],
  hash = {};

function copy(a) {
  let res = [];
  for (let i = 0; i < a.length; i++) res.push(a[i].copy());
  return res;
}

class Node {
  constructor(o, isNum = true, l, r) {
    this.o = o;
    this.l = l;
    this.r = r;
    this.isNum = isNum;
    this.minus = false;
    this.mul = true;
    if (isNum) {
      this.size = 1;
      this.opId = 0;
    } else {
      this.size = l.size + r.size;
      this.opId = "+-*/".indexOf(o) + 1;
    }
  }
  calculate() {
    if (this.isNum) {
      this.term = [this.copy()];
      this.exp = [this.copy()];
    } else {
      this.l.calculate();
      this.r.calculate();
      let [l, r] = [this.l, this.r];
      if (this.o == "+") {
        this.term = copy(l.term);
        this.term.push(...copy(r.term));
        this.exp = [this.copy()];
      } else if (this.o == "-") {
        this.term = copy(l.term);
        for (let t of r.term) {
          let x = t.copy();
          x.minus = x.minus ? false : true;
          this.term.push(x);
        }
        this.exp = [this.copy()];
      } else if (this.o == "*") {
        this.exp = copy(l.exp);
        this.exp.push(...copy(r.exp));
        this.term = [this.copy()];
      } else {
        this.exp = copy(l.exp);
        for (const t of r.exp) {
          let x = t.copy();
          x.mul ^= true;
          this.exp.push(x);
        }
        this.term = [this.copy()];
      }
    }
  }

  copy() {
    let res;
    if (this.isNum) {
      res = new Node(this.o);
      res.minus = this.minus;
      res.mul = this.mul;
    } else {
      res = new Node(this.o, false, this.l.copy(), this.r.copy());
      res.minus = this.minus;
      res.mul = this.mul;
    }
    return res;
  }

  test() {
    this.calculate();
    if (this.isNum) return "abcd"[this.o];
    let res = "";
    if (this.o == "+" || this.o == "-") {
      res = this.term
        .filter(e => !e.minus)
        .sort((a, b) => (a.smaller(b) ? -1 : 1))
        .map(e => e.test())
        .join("+");
      let tmp = this.term
        .filter(e => e.minus)
        .sort((a, b) => (a.smaller(b) ? -1 : 1))
        .map(e => "-" + e.test())
        .join("");
      if (tmp != "") res += tmp;
      return "(" + res + ")";
    }
    res = this.exp
      .filter(e => e.mul)
      .sort((a, b) => (a.smaller(b) ? -1 : 1))
      .map(e => e.test())
      .join("*");
    let tmp = this.exp
      .filter(e => !e.mul)
      .sort((a, b) => (a.smaller(b) ? -1 : 1))
      .map(e => "/" + e.test())
      .join("");
    if (tmp != "") res += tmp;
    return res;
  }

  smaller(other) {
    if (this.size != other.size) return this.size < other.size;
    if (this.opId != other.opId) return this.opId < other.opId;
    if (this.size == 1) return this.o < other.o; // two number
    return this.l.o * 4 + this.r.o < other.l.o * 4 + other.r.o;
  }

  value() {
    if (this.isNum) return values[this.o];
    let [l, r] = [this.l.value(), this.r.value()];
    return eval(`(${l})${this.o}(${r})`);
  }
}

function f(s, nodes) {
  let n = nodes.length,
    ops = ["+", "-", "*", "/"],
    l,
    r,
    i,
    j,
    o,
    new_arr,
    res;
  if (n == 1) return exps.push(nodes[0]);
  for (i = 0; i < n - 1; i++) {
    [l, r] = [nodes[i], nodes[i + 1]];
    for (j = 0; j < 4; j++) {
      o = ops[j];
      if (o == "+" || o == "*") {
        if (!l.smaller(r)) continue;
      }
      new_arr = [];
      for (k = 0; k < n; k++) {
        if (k == i) new_arr.push(new Node(o, false, l, r));
        else if (k == i + 1) continue;
        else new_arr.push(nodes[k]);
      }
      f(s, new_arr);
    }
  }
  return null;
}

function perm(xs) {
  let ret = [];

  for (let i = 0; i < xs.length; i = i + 1) {
    let rest = perm(xs.slice(0, i).concat(xs.slice(i + 1)));

    if (!rest.length) {
      ret.push([xs[i]]);
    } else {
      for (let j = 0; j < rest.length; j = j + 1) {
        ret.push([xs[i]].concat(rest[j]));
      }
    }
  }
  return ret;
}

function equalTo24(...a) {
  values = a;
  if (exps[0] === undefined) {
    let config = perm([0, 1, 2, 3]);
    for (i = 0; i < 24; i++)
      f(
        24,
        config[i].map(e => new Node(e, true))
      );
    for (const exp of exps) {
      if (exp.test() in hash) continue;
      hash[exp.test()] = 1;
      shorten.push(exp);
    }
  }

  for (const exp of shorten) {
    if (Math.abs(exp.value() - 24) < 1e-6) {
      return exp
        .test()
        .replace("a", a[0])
        .replace("b", a[1])
        .replace("c", a[2])
        .replace("d", a[3]);
    }
  }
  return "It's not possible!";
}
