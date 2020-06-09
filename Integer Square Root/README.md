Source: [Codewars.com](https://www.codewars.com/kata/58a3fa665973c2a6e80000c4)

# Task

For each given a number N, the integer S is called `integer square root` of N if `S x S <= N` and `(S+1) x (S+1) > N`.

In other words, `S = Math.floor(Math.sqrt(N))`

Your task is to calculate the `integer square root` of a given `Number`.

Note: Input is given in string format. That is, the `Number` may be very very large ;-)

# Example

For: `Number = "4"`, result = `"2"`.

For: `Number = "17"`, result = `"4"`.

For: `Number = "101"`, result = `"10"`.

For: `Number = "23232328323215435345345345343458098856756556809400840980980980980809092343243243243243098799634"`, result = `"152421548093487868711992623730429930751178496967"`.

# Input/Output

- `[input]` string `Number`

number in decimal form. `0 < Number < 10^100`

- `[output]` a string

integer squareroot of `Number`.
