/* ------------------ GLOBAL VARIABLES ------------------ */

var s, fLeftmost;

/* -------------- REGEXP-RELATED FUNCTIONS  ------------- */

const notNull = x => x !== null;
const to_s = x => (x instanceof RegExp ? x.source : x);
const rReset = r => (r.lastIndex = 0);
const rGroup = r => RegExp("(" + r.source + ")");
const rZeroOrOne = r => rConcat("(", r.source, ")?");
const rConcat = (...r) => rGroup(RegExp(r.reduce((r, s) => r + to_s(s), "")));
const rOr = (...r) => rGroup(RegExp(r.map(r => to_s(r)).join("|")));
const eat = (s, r) => {
  rReset(r);
  let res = r.exec(s);
  remain = s.slice(res[0].length);
  return [res[0], remain];
};
const jump = (s, r) => (taste(s, r) ? eat(s, r)[1] : s);
const taste = (s, r) => {
  if (s == "") return false;
  rReset(r);
  return !((res = r.exec(s)) === null || res.index != 0);
};
const tasteAdd = (s, t, c, a) => {
  if (taste(s, t)) ([x, s] = eat(s, t)), fAdd(a, c(x));
  return s;
};

/* ---------- ORGANIC CHEMISTRY SPECIFICATIONS ---------- */
const VALENCE = [
  ["Br", "Cl", "F", "H", "I"],
  ["O", "S"],
  ["As", "N", "P"],
  ["C"]
];
const RADICALS = [
  null,
  "meth",
  "eth",
  "prop",
  "but",
  "pent",
  "hex",
  "hept",
  "oct",
  "non",
  "dec",
  "undec",
  "dodec",
  "tridec",
  "tetradec",
  "pentadec",
  "hexadec",
  "heptadec",
  "octadec",
  "nonadec",
  "benzene",
  "phen"
];
const MULTIPLIERS = [
  null,
  null,
  "di",
  "tri",
  "tetra",
  "penta",
  "hexa",
  "hepta",
  "octa",
  "nona",
  "deca",
  "undeca",
  "dodeca",
  "trideca",
  "tetradeca",
  "pentadeca",
  "hexadeca",
  "heptadeca",
  "octadeca",
  "nonadeca"
];
const REORDER_RADICALS = [
  null,
  "undec",
  "dodec",
  "tridec",
  "tetradec",
  "pentadec",
  "hexadec",
  "heptadec",
  "octadec",
  "nonadec",
  "benzene",
  "phen",
  "meth",
  "eth",
  "prop",
  "but",
  "pent",
  "hex",
  "hept",
  "oct",
  "non",
  "dec"
];
const REORDER_MULTIPLIERS = [
  "deca",
  "undeca",
  "dodeca",
  "trideca",
  "tetradeca",
  "pentadeca",
  "hexadeca",
  "heptadeca",
  "octadeca",
  "nonadeca",
  "di",
  "tri",
  "tetra",
  "penta",
  "hexa",
  "hepta",
  "octa",
  "nona"
];
const ELEMENTS = ["C", "H", "O", "N", "F", "Cl", "Br", "I", "S", "As", "P"];
const SUFFIXES = [
  "oic acid",
  "oate",
  "ol",
  "al",
  "one",
  "oic acid",
  "carboxylic acid",
  "oate",
  "ether",
  "amide",
  "amine",
  "imine",
  "benzene",
  "thiol",
  "phosphine",
  "arsine"
];
const PREFIXES = [
  "hydroxy",
  "oxo",
  "carboxy",
  "oxycarbonyl",
  "oyloxy",
  "formyl",
  "oxy",
  "amido",
  "amino",
  "imino",
  "phenyl",
  "mercapto",
  "phosphino",
  "arsino",
  "fluoro",
  "chloro",
  "bromo",
  "iodo"
];
const FUNCTION = [
  {
    F: ["fluoro"],
    Cl: ["chloro"],
    Br: ["bromo"],
    I: ["iodo"],
    S: ["mercapto", "thiol"],
    N: ["amine", "amino"],
    As: ["arsine", "arsino"],
    P: ["phosphine", "phosphino"],
    O: ["oxy", "hydroxy", "ol"]
  },
  {
    CO: ["formyl"],
    N: ["imino", "imine"],
    ON: ["amide", "amido"],
    O: ["al", "one", "oxo"],
    CO2: ["carboxy", "oxycarbonyl", "carboxylic acid"],
    O2: ["oyloxy", "oate", "oic acid", "oicacid"]
  }
];
/* ----------------------- TOKENS ----------------------- */

const tPositions = /(\d+,)*\d+/;
const tHyphen = /\-/;
const tOpen = /\[/;
const tSpace = / /;
const tCyclo = /cyclo/;
const tAlkane = /ane?/;
const tAlkyl = /yl/;
const tAlkene = /ene?/;
const tAlkyne = /yne?/;
const tLikedAlkane = token =>
  rConcat(
    rZeroOrOne(rConcat(tHyphen, tPositions, tHyphen)),
    rConcat(rZeroOrOne(tMultipliers), token)
  );
const tRadicals = rConcat(
  rZeroOrOne(tCyclo),
  rOr(...REORDER_RADICALS.filter(notNull))
);
const tMultipliers = rOr(
  rOr(...REORDER_MULTIPLIERS),
  rConcat(rOr(...REORDER_MULTIPLIERS), /n/)
);
const tOrderMultipliers = rOr(
  rOr(...MULTIPLIERS.filter(notNull)),
  rConcat(rOr(...MULTIPLIERS.filter(notNull)), /n/)
);
const tPrefixFunction = rOr(...PREFIXES);
const tSuffixFunction = rOr(...SUFFIXES);
const tAlkeneFunction = tLikedAlkane(tAlkene);
const tAlkyneFunction = tLikedAlkane(tAlkyne);
const tAlkylExtent = rOr(
  tPrefixFunction,
  rConcat(
    tRadicals,
    rZeroOrOne(tAlkeneFunction),
    rZeroOrOne(tAlkyneFunction),
    rZeroOrOne(tAlkane),
    rOr(tAlkyl, tPrefixFunction)
  )
);

/* ----------------- FORMULAR MANIPULATION ----------------- */

const fNew = () => {
  return { branches: [], delta: 0 };
};
const fComplete = a => {
  let [x, _, n, c] = [...Array(4)].map((_, i) =>
    VALENCE[i].map(e => a[e] || 0).reduce((r, e) => r + e, 0)
  );
  a.H = ~~((c - x / 2 + n / 2 + 1 - a.delta) * 2);
};
const fClean = a => {
  fComplete(a);
  let res = ELEMENTS.reduce((r, e) => {
    a[e] && (r[e] = a[e]);
    return r;
  }, {});
  res.H = res.H || 0;
  return res;
};
const fCopy = a => to_f(f2s(a), a.delta);
const f2s = a => {
  let res = "";
  for (const e of ELEMENTS)
    if (a[e] !== undefined && a[e] != 0) res += `${e}${a[e] == 1 ? "" : a[e]}`;
  return res + `[${a.delta}]`;
};
const to_f = (s, d) => {
  let m,
    r = /([A-Z][a-z]?)(\-?\d*)/g,
    res = fNew();
  while ((match = r.exec(s)))
    res[match[1]] = !match[2] ? 1 : parseInt(match[2]);
  res.delta = d;
  return res;
};
const fAdd = (a, b) => {
  a.delta += b.delta;
  for (let e in b) if (ELEMENTS.indexOf(e) != -1) a[e] = (a[e] || 0) + b[e];
};
const fAddN = (a, b, n) => [...Array(n)].reduce((r, _) => fAdd(a, b), a);

/* ----------------------- CONVERTER ----------------------- */

const iRadicals = s => RADICALS.indexOf(s);

const iMultipliers = s => (s === undefined ? 1 : MULTIPLIERS.indexOf(s));

const cRadicals = s => {
  if (s == "benzene" || s == "phen") return to_f("C6", 4);
  let m = tRadicals.exec(s);
  let [n, hasCyclo] = [iRadicals(m[4]), !!m[2]];
  return to_f(`C${n}`, hasCyclo);
};

const cLikedAnkane = s => {
  let multiple;

  s = jump(s, tHyphen);
  s = jump(s, tPositions);
  s = jump(s, tHyphen);

  if (taste(s, tMultipliers, 1)) {
    [multiple, s] = eat(s, tMultipliers);
  }
  return to_f("", iMultipliers(multiple) * (taste(s, tAlkene, 1) ? 1 : 2));
};

const cFunction = t => {
  for (const delta of [0, 1])
    for (const formula in FUNCTION[delta])
      if (FUNCTION[delta][formula].indexOf(t) != -1)
        return to_f(formula, delta);
};

/* ----------------------- PARSERS ----------------------- */

function findClose(s) {
  for (let i = 0, depth = 0; i < s.length; i++) {
    if (s[i] == "[") depth++;
    else if (s[i] == "]" && !--depth) return i;
  }
}

function getBranch(s, outer, previous) {
  let pos,
    multiple,
    prefix,
    t,
    r,
    children = [],
    _save = s,
    res = {},
    f = fNew(),
    cur = fNew();

  s = jump(s, tSpace);
  s = jump(s, tHyphen);

  if (taste(s, tPositions, 1)) {
    [pos, s] = eat(s, tPositions, 1);
  }

  s = jump(s, tHyphen);

  if (taste(s, tMultipliers, 1)) {
    const reset = () => {
      s = multiple + s;
      multiple = undefined;
    };
    [multiple, s] = eat(s, tMultipliers);
    let m = iMultipliers(multiple);
    if (pos) {
      let n = pos.split(",").length;
      if (n != m) {
        reset();
        [multiple, s] = eat(s, tOrderMultipliers);
        m = iMultipliers(multiple);
        if (n != m) reset();
      }
    } else if (m > 2 && (outer || taste(s, /dec/))) reset();
  }

  if (taste(s, tOpen, 1)) {
    closeBracket = findClose(s);
    children.push(s.slice(1, closeBracket));
    s = s.slice(closeBracket + 1);
  }

  if (!taste(s, tAlkylExtent, 1)) return { result: false, remain: _save };

  [prefix, s] = eat(s, tAlkylExtent);

  // CONVERT

  for (const child of children) fAdd(cur, getBranch(child, prefix).f);

  prefix = tasteAdd(prefix, tRadicals, cRadicals, cur);
  prefix = tasteAdd(prefix, tAlkeneFunction, cLikedAnkane, cur);
  prefix = tasteAdd(prefix, tAlkyneFunction, cLikedAnkane, cur);

  if (!taste(prefix, tAlkyl))
    prefix = tasteAdd(jump(prefix, tAlkane), tPrefixFunction, cFunction, cur);

  if (taste(s, tSpace)) {
    fLeftmost = fCopy(cur);
    multiple = undefined;
  }

  fAddN(f, cur, iMultipliers(multiple));

  while ((r = getBranch(s, outer, true)).result) fAdd(f, r.f), (s = r.remain);
  return { f: f, result: true, remain: s };
}

function getSuffix(s, outer) {
  let multiple,
    children = [],
    res,
    cur = fNew(),
    f = fNew();

  s = jump(s, tHyphen);
  s = jump(s, tPositions);
  s = jump(s, tHyphen);

  if (taste(s, tMultipliers, 1)) {
    [multiple, s] = eat(s, tMultipliers);
  }

  if (taste(s, tOpen, 1)) {
    closeBracket = findClose(s);
    children.push(s.slice(1, closeBracket));
    s = s.slice(closeBracket + 1);
  }

  multiple = iMultipliers(multiple);

  if (!taste(s, tSuffixFunction)) return { result: false };

  [t, s] = eat(s, tSuffixFunction);
  cur = cFunction(t);

  for (const child of children) fAdd(cur, getBranch(child, t).f);

  fAddN(f, cur, multiple);

  res = { f: f, remain: s, result: true };
  if (t == "oate") res.multiple = multiple;
  return res;
}

function parse(_s) {
  (s = _s), (fLeftmost = fNew());
  let fMain = fNew(),
    fPrefix = fNew(),
    fSuffix = fNew(),
    r,
    t;

  while ((r = getBranch(s)).result) fAdd(fPrefix, r.f), (s = r.remain);

  if (s == "ether") {
    fAdd(fPrefix, to_f("O", 0));
    return fClean(fPrefix);
  }

  s = jump(s, tSpace);
  s = tasteAdd(s, tRadicals, cRadicals, fMain);
  s = jump(s, tAlkane);
  s = tasteAdd(s, tAlkeneFunction, cLikedAnkane, fMain);
  s = tasteAdd(s, tAlkyneFunction, cLikedAnkane, fMain);

  while ((r = getSuffix(s)).result) {
    if (r.multiple) {
      t = fNew();
      fAddN(t, fLeftmost, r.multiple - 1);
      fLeftmost = t;
    }
    fAdd(fSuffix, r.f);
    s = r.remain;
  }

  fAdd(fMain, fLeftmost);
  fAdd(fMain, fPrefix);
  fAdd(fMain, fSuffix);

  return fClean(fMain);
}
