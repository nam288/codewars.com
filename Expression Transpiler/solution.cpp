#include <iostream>
#include <math.h>
#include <string>
#include <utility>
#include <regex>
#include <sstream>
#include <iomanip>
#include <igloo/igloo_alt.h>
#include <algorithm>
#include <set>
#include <regex>
using namespace std;
using namespace igloo;
typedef long long ll;
typedef double db;
typedef pair<int, int> pii;
typedef vector<int> vi;
typedef vector<pii> vpii;
typedef vector<vi> vvi;
typedef vector<bool> vb;
typedef vector<string> vs;
typedef vector<char> vc;
typedef vector<vc> vvc;
typedef vector<char> NAMENUM;
typedef vvc LAM_PARAM;
typedef vvc LAM_STMT;
typedef pair<vvc, vvc> LAMBDA;

#define REP(i,a,b) for (int i=a; i<=b; i++)
#define REPR(i,a,b) for (int i=a; i>=b; i--)
#define fa(i,v) for (auto i: v)
#define all(c) c.begin(), c.end()
#define sz(x) ((int)((x).size()))
#define what_is(x) cerr << #x << " is " << x << "\n";
#define F first
#define S second
#define pb push_back
#define shift _shift(tokens)

bool fail = false;

void split(const string &s, char delim, vector<string> &elems) {
    stringstream ss(s);
    string item;
    while (getline(ss, item, delim)) {
        elems.push_back(item);
    }
}

vector<string> split(const string &s, char delim) {
    vector<string> elems;
    split(s, delim, elems);
    return elems;
}

bool include(vc& tokens, char c, vc v) {
    return tokens.empty() == false and find(all(v), c) != v.end();
}

void pr(vc& tokens) {
    fa(i, tokens) cout << i; cout << endl;
}

void _shift(vc &tokens)
{
    if (tokens.empty()) return;
    assert(!tokens.empty());
    tokens.erase(tokens.begin());
}

void skip(vc& tokens, vc ifEqual) {
    while (tokens.empty() == false and find(all(ifEqual), tokens.front()) != ifEqual.end() )
        shift;
}

struct NameNumber {
    string val;
    vector<char> invalid = {' ', ',', '-','(',')', '}', '\n', '{'};
    NameNumber(vc& tokens) {
        skip(tokens, {' ', '\n'});


        while (tokens.empty() == false and find(all(invalid), tokens.front()) == invalid.end()) {
            val.pb(tokens.front());
            shift;
        }
        skip(tokens, {' ', '\n'});
    }
    void print() {
        cout << "[NameNumber " + val + "] ";
    }
    NameNumber() {};
};

struct LambdaComponent {
    vector<NameNumber> val;
    int type = -1;
    bool isnil = true;
    LambdaComponent(vc& tokens, int type, vc separators, vc ender) {
        while (!include(tokens, tokens.front(), ender) and tokens.empty() == false) {
            if (include(tokens, tokens.front(), separators)) shift;
            val.pb(NameNumber(tokens));
        }
        while (include(tokens, tokens.front(), ender)) shift;
        this->type = type;
        isnil = val.empty();
    }

    LambdaComponent() {};

    void print() {
        cout << "[" << (type == 0 ? "LAMBDA_PARAM" : "LAMBDA_STMT") << " ";
        if (isnil) cout << "NIL";
        fa(i, val) i.print();
        cout << "]";
    }
    string trans() {
        if (val.empty()) return "";
        string res = "";
        for (int i = 0; i<sz(val)-1; i++) {
            res += val[i].val + ",;"[type];
        }
        res += val[sz(val)-1].val + (type == 1 ? ";" : "");
        return res;
    }
};

struct Lambda {
    LambdaComponent lambdaparams, lambdastmts;
    bool empty = true;
    bool isnil = true;
    Lambda(vc& tokens) {
        skip(tokens, {' ', '\n'});
        if (tokens.front() != '{') {
            return;
        }
        shift;
        bool hasParam = false;
        for (int i = 0; i < sz(tokens); i++) {
            if (tokens[i] == '}') break;
            hasParam |= tokens[i] == '-';
        }
        if (hasParam)
            lambdaparams = LambdaComponent(tokens, 0, {' ', ','}, {'-', '>'});
        else
            lambdaparams.type = 0;
        bool hasStmt = false;
        for (int i = 0; i < sz(tokens); i++) {
            if (tokens[i] == '}') break;
            hasStmt |= isalnum(tokens[i]);
        }
        if (hasStmt)
            lambdastmts = LambdaComponent(tokens, 1, {' '}, {'}'});
        else {
            lambdastmts.type = 1;
            shift;
        }
        empty = lambdastmts.isnil and lambdaparams.isnil;
        isnil = false;
    }


    void print() {
        cout << "[LAMBDA\n";
        if (isnil)
            cout << "\t" << "NIL\n";
        else if (empty)
            cout << "\t" << "EMPTY\n";
        else {

            cout << "\t"; lambdaparams.print(); cout << "\n";
            cout << "\t"; lambdastmts.print(); cout << "\n";
        }
        cout << "]";
    }
    Lambda() {};

    string trans() {
        return "(" + lambdaparams.trans() + "){" + lambdastmts.trans() + "}";
    }
};

struct Exp {
    Lambda _lambda;
    NameNumber _nameNumber;
    enum TypeExpression {LambdaType, NameType, Nil};
    TypeExpression type = Nil;
    Exp(vc& tokens) {
        skip(tokens, {' ', '\n'});
        skip(tokens, {' ', '\n'});
        if (tokens.front() == ')') {
            return;
        }
        if (tokens.front() == '{') {
            _lambda = Lambda(tokens);
            type = LambdaType;
        }
        else  {
            _nameNumber = NameNumber(tokens);
            type = NameType;
        }
    }

    void print() {
        cout << "[EXP ";
        if (_lambda.isnil)
            _nameNumber.print();
        else
            _lambda.print();
        cout << "]\n";
    }
    Exp() {};

    string trans() {
        if (_lambda.isnil)
            return _nameNumber.val;
        return _lambda.trans();
    }
};

struct Parameter {
    vector<Exp> _expressions;
    bool isnil = true;
    bool empty = true;
    Parameter(vc& tokens) {
        skip(tokens, {' ', '\n'});
        if (tokens.front() != '(') {
            cout << "Not found parameter\n";
            cout << "End Parsing parameter \n";
            return;
        }
        shift;
        skip(tokens, {' ', '\n'});
        if (tokens.front() == ',' or tokens.front() == '-') return;
        while (!include(tokens, tokens.front(), {')'}) and tokens.empty() == false) {
            if (include(tokens, tokens.front(), {',', ' ', '\n'})) shift;
            _expressions.pb(Exp(tokens));
        }
        while (include(tokens, tokens.front(), {')'})) shift;
        isnil = false;
        empty = _expressions.empty();
    }

    Parameter() {};
    void print() {
        cout << "[FUNC_PARAM ";
        if (isnil) cout << "NIL";
        else if (empty) cout << "EMPTY";
        else {
            cout << sz(_expressions) << "\n";
            fa(i, _expressions) i.print();
        }
        cout << "]\n";
    }
    string trans() {
        string res = "";
        if (empty) return "";
        for (int i = 0; i<sz(_expressions)-1; i++) {
            res += _expressions[i].trans() + ",";
        }
        res += _expressions[sz(_expressions)-1].trans();
        return res;
    }
};

struct Function {
    Exp _expression;
    Parameter _parameter;
    Lambda _lamda;
    bool isnil = true;
    Function(vc& tokens) {
        skip(tokens, {' ', '\n'});
        if (tokens.front() == '(')
            return;
        _expression = Exp(tokens);
        skip(tokens, {' ', '\n'});

        if (tokens.front() == '(') {
            _parameter = Parameter(tokens);
            if (_parameter.isnil) return;
            skip(tokens, {' ', '\n'});
            if (tokens.front() == '{') {
                _lamda = Lambda(tokens);
                skip(tokens, {' ', '\n','}'});
                if (tokens.empty() == false) {
                    isnil = true;
                    return;
                }

            }

            else if (tokens.empty() == false) {
                isnil = true;
                return;
            }
        } else {
            if (tokens.front() == '{')
                _lamda = Lambda(tokens);
            else if (tokens.empty() == false) {
                isnil = true;
                return;
            }
        }
        isnil = false;
    }

    void print() {
        cout << "\nFUNCTION DESCRIPTION\n";
        cout << "------------------------\n";
        cout << "FUNCTION EXPRESSION\n";
        _expression.print();
        cout << "------------------------\n";
        cout << "FUNCTION PARAMETERS\n";
        _parameter.print();
        cout << "------------------------\n";
        cout << "FUNCTION LAMBDA\n";
        _lamda.print();
        cout << "------------------------\n";
    }

    string trans() {
        if (_parameter.empty and _lamda.isnil) {
            return _expression.trans() + "()";
        }
        if (_parameter.isnil or _parameter.empty) {
            return _expression.trans() + "(" + _lamda.trans() + ")";
        }
        return _expression.trans() + "(" + _parameter.trans() + (_lamda.isnil ? "" : "," + _lamda.trans() ) + ")";
    }
};

bool checkValidName(string s) {
    char change_to = ' ';
    set<char> otherChars = {'-','>', ',','(',')','{','}'};

    auto transformation_operation = [otherChars, change_to](char c)
    {
        return otherChars.count(c) ? change_to : c;
    };
    std::transform(s.begin(), s.end(), s.begin(), transformation_operation);
    auto names = split(s, ' ');
    fa(i, names) {
        bool allDigit = true;
        fa(j, i) if (!isdigit(j)) allDigit = false;
        if (i!="" and isdigit(i[0]) and !allDigit) return false;
    }
    return true;
}


const char *transpile (const char* e) {
    cout << "#" << e  << "#" << endl;
    if (e == "") return "";
    vc tokens;
    vc invalidCharacter = {'%','^', '&', '*'};
    string tmp = string(e);
    if (!checkValidName(tmp)) return "";
    int cntParen = 0, cntCurly = 0;
    fa(i, tmp) {
        if (i == '(') cntParen ++;
        else if (i == '{') cntCurly++;
        else if (i == ')') {
            cntParen--;
            if (cntParen<0) return "";
        } else if (i == '}') {
            cntCurly--;
            if (cntCurly<0) return "";
        }
    }
    if (cntCurly or cntParen) return "";
    std::smatch m;
    regex nonComma("\\([\\s\\n]*\\w[\\s\\n]+\\w.*\\)|^[\\s\\n]*$|\\{[\\s\\n]*->|(\\{\\}){3,}|\\{[\\s\\n]*\\w[\\s\\n]+\\w.*\\}|->.*\\w[\\s\\n]*,[\\s\\n]*\\w\\}|,\\w\\s+[a-z]+\\}");
    if (regex_search(tmp, m, nonComma)) return "";

    fa(iter, tmp) {
        if (find(all(invalidCharacter), iter) != invalidCharacter.end())
            return "";
        tokens.pb(iter == '\n' ? ' ' : iter);
    }
    Function func(tokens);
    auto res = func.trans();

    cout << res << endl;
    cout << "@@" << func.isnil << endl;

    if (fail or func.isnil) return "";
    if (res.find(",)") != string::npos) return "";

    char *y = new char[res.length() + 1];

    std::strcpy(y, res.c_str());
    return y;
}
