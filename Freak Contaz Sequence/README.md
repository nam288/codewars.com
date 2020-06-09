Source: [Codewars.com](https://www.codewars.com/kata/58b8e48a4dda07e85f00013a)

# Task

`Freak Contaz Sequence` is another version of Collatz sequence of integers is obtained from the starting a(1) in the following way:

````
 a(n + 1) = a(n) / 3 if a(n) is divisible by 3.
 We shall denote this as a large downward step, "D".

 a(n + 1) = (4 * a(n) + 2) / 3 if a(n) divided by 3 gives a remainder of 1.
 We shall denote this as an upward step, "U".

 a(n + 1) = (2 * a(n) - 1) / 3 if a(n) divided by 3 gives a remainder of 2.
 We shall denote this as a small downward step, "d".```

 The sequence stops when a(k) = 1 for some k.

 Given any integer, we can list out the sequence of steps:

 For instance if `a(1) = 231`, then the sequence {an} = `{231,77,51,17,11,7,10,14,9,3,1} `corresponds to the steps `"DdDddUUdDD"`.

 Of course, there are other sequences that begin with that same sequence `"DdDddUUdDD...."`.

 For example, if `a = 1004064`, then the sequence is `"DdDddUUdDDDdUDUUUdDdUUDDDUdDD"`.

 Your task is to find the `smallest` positive number N > 1 such that the sequence begins with the string `s`. That is, if `s = "DdDddUUdDD"`, the result should be `231` instead of `1004064`.

 Note: For `a(1) = 1`, the sequence terminate immediately and the string of length 0 is returned!

# Input/Output


 - `[input]` string `s`

 a string, corresponds to the steps.


 - `[output]` integer `N`

 The answer N fits in a integer, `2 <= N <= 10^10`.
````
