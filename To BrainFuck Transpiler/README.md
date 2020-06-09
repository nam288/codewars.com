Source: [Codewars.com](https://www.codewars.com/kata/59f9cad032b8b91e12000035)

## Requirement

You are given a `code` follows the following specification, and are going to transpile it to BrainFuck.

## Specification

### Lexical Syntax

The syntax for lexical parsing is described in an ENBF like syntax.
Literal strings are enclosed in pairs of ' or " characters below, using Unicode escapes.

```txt
EOL -> 'U+000A'
CommentPrefix -> '//' | '--' | '#'
Comment -> CommentPrefix <all characters until EOL or EOF>
VarPrefix -> '$' | '_'
    | 'a' | 'b' | ... | 'z'
    | 'A' | 'B' | ... | 'Z'
VarSuffix -> VarPrefix | Digit
CharElement -> <any characters other than ', ", or \>
    | '\\' | "\'" | '\"'
    | '\n' | '\r' | '\t'
CharQuote -> "'"
Char -> CharQuote CharElement CharQuote
StringQuote -> '"'
String -> StringQuote CharElement* StringQuote
Digit -> '0' | '1' | ... | '9'
Number -> '-' Digit+ | Digit+ | Char
```


### Grammar

The language grammar for parsing is described in an ENBF like syntax.
Literal strings are enclosed in pairs of ' or " characters below.

```txt

Program -> [ Statement ] [ Comment ] [ EOL Program ]

VarName -> VarPrefix VarSuffix*
VarNameOrNumber -> VarName | Number
VarNameOrString -> VarName | String
VarSingle -> VarName | ListName '[' Number ']'

Statement -> "var" VarSingle+
    | "set" VarName VarNameOrNumber

    | "inc" VarName VarNameOrNumber
    | "dec" VarName VarNameOrNumber

    | "add" VarNameOrNumber VarNameOrNumber VarName
    | "sub" VarNameOrNumber VarNameOrNumber VarName
    | "mul" VarNameOrNumber VarNameOrNumber VarName
    | "divmod" VarNameOrNumber VarNameOrNumber VarName VarName
    | "div" VarNameOrNumber VarNameOrNumber VarName
    | "mod" VarNameOrNumber VarNameOrNumber VarName

    | "cmp" VarNameOrNumber VarNameOrNumber VarName

    | "a2b" VarNameOrNumber VarNameOrNumber VarNameOrNumber VarName
    | "b2a" VarNameOrNumber VarName VarName VarName

    | "lset" ListName VarNameOrNumber VarNameOrNumber
    | "lget" ListName VarNameOrNumber VarName

    | "ifeq" VarName VarNameOrNumber
    | "ifneq" VarName VarNameOrNumber
    | "wneq" VarName VarNameOrNumber
    | "proc" ProcedureName ProcedureParameter*
    | "end"
    | "call" ProcedureName ProcedureParameter*

    | "read" VarName
    | "msg" VarNameOrString+

    | "rem" <all characters until EOL or EOF>

ListName -> VarName
ProcedureName -> VarName
ProcedureParameter -> VarName

```

Note

+ One or more whitespace characters are used to separate non-terminals in the grammar (except for 'Comment').
+ Instruction names and variable names are case insensitive, i.e. lookup ignores case.
+ Character literals should be translated to their ASCII encoded numeral (eg. `'z' -> 122`).
+ If a number is not in range [0,255] wrap it into this range . (eg. `450 -> 194`, `-450 -> 62`)

### Instruction
#### Variable
`var VarSingle+`. Define one or more variables, some could be lists.
The length of a list will always be in range [1,256].
eg. `var A B C[100] D` defines variable `A`, `B`, `C` and `D` where `C` represent a 100-length list (or you call it an array).
`var X [ 80 ]` is also acceptable.
All variables and all list slots are initialized to `0`.

`set a b`. Set value of variable `a` to `b`.
Examples : `set X 30`, `set X Y`.

**Note** Variables can be defined everywhere except inside a `procedure`, and they are all global variables, cannot be used before defined.

#### Arithmetic
`inc a b`. Increase the value of `a` as `b`. Equivalent to C : `a += b`.
Examples : `inc X 10`, `inc X Y`.

`dec a b`. Decrease the value of `a` as `b`. Equivalent to C : `a -= b`.
Examples : `dec Y 10`, `dec X Y`.


`add a b c`. Add `a` and `b` then store the result into `c`. Equivalent to C : `c = a + b`.
Examples : `add 10 X Y`, `add X Y X`

`sub a b c`. Subtract `b` from `a` then store the result into `c`. Equivalent to C : `c = a - b`.
Examples : `sub X 20 Y`, `sub X Y Y`

`mul a b c`. Multiply `a` and `b` then store the result into `c`. Equivalent to C : `c = a * b`.
Examples : `mul 10 20 X`, `mul X 10 X`

`divmod a b c d`. Divide `a` and `b` then store the quotient into `c` and the remainder into `d`. Equivalent to C : `c = floor(a / b), d = a % b`.
Examples : `divmod 20 10 X Y`, `divmod X Y X Y`, `divmod X 10 Y X`.

`div a b c`. Divide `a` and `b` then store the quotient into `c`. Equivalent to C : `c = floor(a / b)`.
Examples : `div 10 X X`, `div X X X`

`mod a b c`. Divide `a` and `b` then store the remainder into `c`. Equivalent to C : `c = a % b`.
Examples : `mod 10 X X`, `mod X X Y`


**Note** The behavior when divisor is 0 is not defined, and will not be tested.

`cmp a b c`. Compare `a` and `b`.
If `a` < `b` store -1(255) into `c`.
If `a` == `b` store 0 into `c`.
If `a` > `b` store 1 into `c`.
Examples : `cmp 10 10 X`, `cmp X X X`, `cmp X 20 Y`

`a2b a b c d`. ASCII To Byte. Treat `a`, `b` and `c` as ASCII digits and store the number represents those digits into `d`.
Equivalent to C : `d = 100 * (a - 48) + 10 * (b - 48) + (c - 48)`.
Examples : `a2b '1' '5' '9' X`, `a2b '0' X Y X`

`b2a a b c d`. Byte To ASCII. The reverse operation of `a2b`.
Equivalent to C : `b = 48 + floor(a / 100), c = 48 + floor(a / 10 % 10), d = 48 + (a % 10)`.
Examples : `b2a 159 X Y Z`, `b2a 'z' X Y Z`, `b2a X X Y Z`


#### List
`lset a b c`. Set `c` into index `b` of list `a`. Equivalent to C : `a[b] = c`.
Examples : `lset X 0 20`, `lset X Y Z`

`lget a b c`. Read index `b` of list `a` into `c`. Equivalent to C : `c = a[b]`.
Examples : `lget X 0 X`, `lget X Y Z`

**Note** The behavior of accessing invalid index (negative or too big) is not defined, and will not be tested.

#### Control Flow
`ifeq a b`. Execute the block when `a` equals to `b`. Equivalent to C : `if (a == b) {`

`ifneq a b`. Execute the block when `a` not equals to `b`. Equivalent to C : `if (a != b) {`

`wneq a b`. Execute the block repeatly while `a` not equals to `b`. Equivalent to C : `while (a != b) {`

`proc procedureName procedureParameter`. Begin a procedure block.

`end`. The end of `ifeq`, `ifneq`, `wneq` and `proc`. Equivalent to C : `}`

`call procedureName argument`. Invoke a procedure.

Notes

+ `ifeq`, `ifneq` and `wneq` can be nested, can appear inside a `proc`.
+ `proc` can not be nested.
+ `call` can invoke a `proc` before it is defined.
+ `call` can be inside a `proc`.
+ Procedures can not be directly or indirectly recursive.
+ Arguments are passed to a procedure by reference, which means procedures are kind of marco.
+ Procedure paramaters can have same name with global variables, in which case its content refers to the parameter instead of global variables.

#### Interactive
`read a`. Read into `a`, using the BF ',' operator.

`msg`. Print message, using the BF '.' operator. String arguments can separate other arguments, no whitespace is needed there.
Examples : `msg "a is " a`, `msg"b ""is"b"\n"`, `msg a b c`

#### Comment
`rem`. Used for whole line comments.

## Error Handling

A complete transpiler would not only accept valid input but also tells the errors in an invalid input.
If any situation mentioned below occured, generate an error on the first occurrence.
There will not be any other invalid forms appears in the final tests. (eg. `msg 20` does not suit the specification but will not be tested)
Also, there will not exist procedures that are not being used.

+ Unknown instructions. `whatever a b c`
+ Number of arguments for an instruction does not match the expectation. `add 20`, `div 20 20 c d`
+ Undefined var names. `var Q\nadd Q Q S`
+ Duplicate var names. `var Q q`, `var Q\nvar Q[20]`
+ Define variables inside a procedure. `proc whatever\nvar Q\nend`
+ Unclosed `[]` pair. `var Q[ 20 S`
+ Expect a variable but got something else. `set 20 20`, `inc "a" 5`
+ Expect a variable but got a list. `var A B[20]\nlset B B 20`
+ Expect a list but got a variable. `var A B[20]\nlset A 0 20`
+ Unclosed `''` pair. `add '0 '1' a`
+ Unclosed `""` pair. `msg "abc`
+ Nested procedures. `proc pa\nproc pb\nend\nend`
+ Duplicate procedure names. `proc a\nend\nproc a\nend`
+ Duplicate parameter names. `proc a Q q\nend`
+ End before beginning a block. `end`
+ Unclosed blocks. `var a\nifeq a 0`
+ Undefined procedure. `call whatever`
+ The length of arguments does not match the length of parameters. `proc a b c\nend\ncall a x`
+ Recursive call.

```txt
var A
set a 20
call Wrap a
proc Say x
    msg "It is "x
    call Wrap X
end
Proc Wrap X
    call Say x
eNd
```

## What should the code be transpiled like
Any valid BrainFuck code with the same functionality.
If you stuck on some instructions, you can check the following links.
[Brainfuck algorithms](https://esolangs.org/wiki/Brainfuck_algorithms)
[INSHAME: Brainfuck](http://www.inshame.com/search/label/Brainfuck)
Actually this kata is inspired by the project `FBF` on INSHAME site.

## Example

```javascript
var code = kcuf(`
var q w e
read q
read w
add q w e
msg q " " w " " e
`)
runBF(Code,'A!') === 'A ! b'
```

Checkout more in example tests.

## About the BrainFuck interpreter

The interpreter used here

+ Accept and ignore characters other than `+-<>,.[]`.
+ Has *infinity* cells.
+ Cells value are wrapped into [0,255].
+ Throws an error when accessing negative indexes.

The following situations will be optimized

+ Continous `+`s.
+ Continous `-`s.
+ Continous `<`s.
+ Continous `>`s.
+ Loops that only contain `+-<>`, return back to be begining position at the end, and totally increasing 1 or decreasing 1 to the begining position. (eg. `[-]`, `[>+<-<+>]`. Not `[>]`, `[->]`, `[>[-]]`)

## Note

+ You do not need to concentrate on the size and performance of the output code, but you may need to be careful if the algorithm you used to transpile an instruction is too slow.
