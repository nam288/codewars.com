var a,
  stack = [],
  heap = {},
  input,
  output = "",
  label2line,
  progStack = [],
  finish,
  p,
  isScan;
var prog = [];
function shift() {
  if (p >= a.length) throw "Out of bounds Stack Error";
  return a[p++];
}

function readInput(int = true) {
  let res = "";
  if (!int) {
    return input.shift();
  } else {
    if (input.length == 0) throw "Empty input";
    while (/\S/.test(input[0])) res += input.shift();
    input.shift();
    return parseInt(res);
  }
}

function tokenize(s) {
  a = [
    ...s
      .replace(/[^ \t\n]/g, "")
      .replace(/ /g, "s")
      .replace(/\t/g, "t")
      .replace(/\n/g, "n")
  ];
}

function binToDec(sign, bin) {
  let res = 0,
    n = bin.length,
    pow = 1,
    i;
  for (i = n - 1; i >= 0; i--, pow *= 2) res += +bin[i] * pow;
  return sign * res;
}

function getNumber() {
  if (a[p] == "n") throw "Invalid number";
  let res,
    sign = shift() == "s" ? 1 : -1,
    bin = "0",
    c;
  while ((c = shift()) != "n") bin += c == "s" ? "0" : "1";
  return binToDec(sign, bin);
}

function getLabel() {
  let res = "",
    c;
  while ((c = shift()) != "n") res += c;
  return res;
}

function pop() {
  if (stack.length == 0) throw "Pop Empty Stack Error";
  return stack.pop();
}

function value_at(i) {
  if (i < 0 || i >= stack.length) throw "Out of bounds Stack Error";
  return stack[i];
}

function getIMP() {
  let res;
  if (a[p] != "t") {
    res = shift() == "s" ? doStack() : doControl();
  } else {
    shift();
    let r = shift();
    res = r == "s" ? doArith() : r == "t" ? doHeap() : doIO();
  }
  return res;
}

function doStack() {
  let cmd = (c = shift()) != "s" ? c + shift() : c,
    l = stack.length,
    n;
  if (/^[st]/.test(cmd)) n = getNumber();
  console.log("Stack", cmd, n);
  if (isScan) return;
  if (cmd == "s") stack.push(n);
  else if (cmd == "ts") stack.push(value_at(l - 1 - n));
  else if (cmd == "tn")
    n < 0 || n >= l ? stack.splice(0, l - 1) : stack.splice(l - n - 1, n);
  else if (cmd == "ns") stack.push(value_at(l - 1));
  else if (cmd == "nt")
    [stack[l - 2], stack[l - 1]] = [stack[l - 1], stack[l - 2]];
  else if (cmd == "nn") pop();
  else throw "Error Command Stack";
}

function doArith() {
  const div = function (a, b) {
    if (a === 0) throw "Zero Division Error";
    return Math.floor(b / a);
  };
  const mod = (a, b) => (a > 0 ? 1 : -1) * Math.abs(b - a * div(a, b));
  let cmd = shift() + shift();
  if (isScan) return;
  if (cmd == "ss") stack.push(pop() + pop());
  else if (cmd == "st") stack.push(-pop() + pop());
  else if (cmd == "sn") stack.push(pop() * pop());
  else if (cmd == "ts") stack.push(div(pop(), pop()));
  else if (cmd == "tt") stack.push(mod(pop(), pop()));
  else throw "Arith Command Error";
}

function doHeap() {
  let cmd = shift();
  if (isScan) return;
  if (cmd == "s") {
    let a = pop(),
      b = pop();
    heap[b] = a;
  } else if (cmd == "t") {
    let val = heap[pop()];
    if (val === undefined) throw "Read Heap Error";
    stack.push(val);
  } else throw "Heap Command Error";
}

function doIO(...args) {
  let cmd = shift() + shift();
  if (isScan) return;
  if (cmd == "ss") output += String.fromCharCode(pop());
  else if (cmd == "st") output += "" + pop();
  else if (cmd == "ts") heap[pop()] = readInput(false).charCodeAt(0);
  else if (cmd == "tt") heap[pop()] = readInput(true);
  else throw "IO Command Error";
}

function doControl() {
  let cmd = shift() + shift(),
    label = /tn|nn/.test(cmd) ? null : getLabel();
  if (cmd == "ss") {
    if (isScan) {
      if (label2line[label] !== undefined) throw "Repeated Label";
      label2line[label] = p;
    }
  } else if (isScan) {
    return;
  } else if (cmd == "tn") {
    if (progStack.length == 0) throw "Empty Program Stack";
    p = progStack.pop();
  } else if (cmd == "nn") {
    finish = true;
  } else if (cmd == "st" || cmd == "sn") {
    progStack.push(p);
    if (label2line[label] === undefined) throw "Undefined label";
    p = label2line[label];
  } else if (cmd == "ts") {
    if (pop() == 0) {
      progStack.push(p);
      if (label2line[label] === undefined) throw "Undefined label";
      p = label2line[label];
    }
  } else if (cmd == "tt") {
    if (pop() < 0) {
      progStack.push(p);
      if (label2line[label] === undefined) throw "Undefined label";
      p = label2line[label];
    }
  } else throw "Control Error";
}

function whitespace(code, inp = "") {
  (stack = []),
    (prog = []),
    (progStack = []),
    (heap = {}),
    (output = ""),
    (input = [...inp]),
    (line = 0),
    (label2line = {}),
    (finish = false),
    (p = 0),
    (isScan = true);
  tokenize(code);
  if (!code.length) throw "Unclean termination";
  while (p < a.length) getIMP();
  isScan = false;
  p = 0;
  while (finish == false) getIMP();
  return output;
}
