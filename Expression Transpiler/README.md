Source: [Codewars.com](https://www.codewars.com/kata/597ccf7613d879c4cb00000f/ruby)

In this Kata, you're going to transpile an expression from one langauge into another language.

The source language looks like Kotlin and the target language looks like Dart. And you **don't need to know neither of them** to complete this Kata.

We're going to transpile a `function call` expression.

If you successfully parsed the input, return `Right output`, otherwise give me `Left "Hugh?"`.
~~~if:java
For Java, return the empty string upon failure, else the transpiled string.
~~~
~~~if:csharp
For C#, return the empty string upon failure, else the transpiled string.
~~~
~~~if:c
For C, return the empty string upon failure, else the transpiled string.
~~~
~~~if:cpp
For C++, return the empty string upon failure, else the transpiled string.
~~~
~~~if:python
For Python, return the empty string upon failure, else the transpiled string.
~~~
~~~if:ruby
For Ruby, return the empty string upon failure, else the transpiled string.
~~~

We have three kinds of basic expressions:

+ names, like `abc`, `ABC`, `run`, `a1`, beginning with `_`/letters and followed by `_`/letters/numbers
+ numbers, like `123`, `2333`, `66666`
+ lambda expressions, like `{ a -> a }`, `{ a, b -> a b }`(source), `(a){a;}`, `(a,b){a;b;}`(target)

We have empty characters `blank space` and `\n`.

The definition of `names` is quite similiar to C/Java. Names like this are invalid:

+ `1a`

You don't have to worry about reserved words here.

Lambda expressions consist of two parts:

+ parameters, they're just names/numbers
+ statements, a list of names/numbers, seperated by whitespaces in source language, by `;` in target language.

Invoking a function is to pass some arguments to something callable(names and lambdas), like `plus(1, 2)`, or `repeat(10, { xxx })`.

There's a syntax sugar in Kotlin: if the last argument is a lambda, it can be out of the brackets. Like, `repeat(10, { xxx })` can be written in `repeat(10) { xxx }`. And if that lambda is the only argument, you can even ignore the brackets. Like: `run({ xxx })` is equaled to `run { xxx }`.

You can refer to the examples at the bottom.

## The source language looks like:

```
function ::= expression "(" [parameters] ")" [lambda]
           | expression lambda

expression ::= nameOrNumber
             | lambda

parameters ::= expression ["," parameters]

lambdaparam ::= nameOrNumber ["," lambdaparam]
lambdastmt  ::= nameOrNumber [lambdastmt]

lambda ::= "{" [lambdaparam "->"] [lambdastmt] "}"
```

Notice: there can be whitespaces among everywhere, it's not a part of the language grammar.

## The target language looks like:

```
function ::= expression "(" [parameters] ")"

expression ::= nameOrNumber
             | lambda

parameters ::= expression ["," parameters]

lambdaparam ::= nameOrNumber ["," lambdaparam]
lambdastmt  ::= nameOrNumber ";" [lambdastmt]

lambda ::= "(" [lambdaparam] "){" [lambdastmt] "}"
```

You shouldn't produce any whitespaces in the target language.

Those examples covered all the language features shown above. Hope you enjoy it :D

`fun()` => `fun()`
`fun(a)` => `fun(a)`
`fun(a, b)` => `fun(a,b)`
`{}()` => `(){}()`
`fun {}` => `fun((){})`
`fun(a, {})` => `fun(a,(){})`
`fun(a) {}` => `fun(a,(){})`
`fun {a -> a}` => `fun((a){a;})`
`{a -> a}(1)` => `(a){a;}(1)`
`fun { a, b -> a b }` => `fun((a,b){a;b;})`
`{a, b -> a b} (1, 2)` => `(a,b){a;b;}(1,2)`
`f { a }` => `f((){a;})`
`f { a -> }` => `f((a){})`\
`{}{}` => `(){}((){})`

~~~if:javascript
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:haskell
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:python
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:ruby
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:java
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:csharp
You have to write your own tokenizer (hint: whitespace is significant to separate some tokens, but can be ignored otherwise).
~~~
~~~if:c
A tokenizer is provided.
~~~
~~~if:cpp
A tokenizer is provided.
~~~
