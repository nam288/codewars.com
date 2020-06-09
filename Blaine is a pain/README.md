Source: [Codewars.com](https://www.codewars.com/kata/59b47ff18bcb77a4d1000076/ruby)

<img src="https://i.imgur.com/ta6gv1i.png?1" />

---

<span style="font-weight:bold;font-size:1.5em;color:red">_Blaine is a pain, and that is the truth</span>&nbsp;- Jake Chambers_

# <span style='color:orange'>Background</span>

Blaine likes to deliberately crash toy trains!

## <span style='color:orange'>_Trains_</span>

Trains look like this

- `Aaaaaaaaaa`
- `bbbB`

The engine and carriages use the same character, but because the only engine is uppercase you can tell which way the train is going.

Trains can be any alphabetic character

- An "Express" train uses `X`
- Normal suburban trains are all other letters

## <span style='color:orange'>_Tracks_</span>

Track pieces are characters `-` `|` `/` `\` `+` `X` and they can be joined together like this

<table>
<tr>
<td><i>Straights</i>
<td width = "20%">
<pre style='background:black'>
----------

</pre>
<td width = "20%">
<pre style='background:black'>
|
|
|
</pre>
<td width = "20%">
<pre style='background:black'>
\
 \
  \
</pre>
<td width = "20%">
<pre style='background:black'>
   /
  /
 /
</pre>
</tr>
<tr>
<td><i>Corners</i>
<td>
<pre style='background:black'>
|
|
\-----
</pre>
<td>
<pre style='background:black'>
     |
     |
-----/
</pre>
<td>
<pre style='background:black'>
/-----
|
|
</pre>
<td>
<pre style='background:black'>
-----\
     |
     |
</pre>

</tr>

<tr>
<td><i>Curves</i>
<td>
<pre style='background:black'>
-----\
      \-----

</pre>
<td>
<pre style='background:black'>
      /-----
-----/

</pre>
<td>
<pre style='background:black'>
  |
  /
 /
 |
</pre>
<td>
<pre style='background:black'>
|
\
 \
 |
</pre>

</tr>
<tr>
<td><i>Crossings</i>
<td>
<pre style='background:black'>
   |
---+---
   |
</pre>
<td>
<pre style='background:black'>
  \ /
   X
  / \
</pre>
<td>
<pre style='background:black'>
   /
---+---
   /
</pre>
<td>
<pre style='background:black'>
   | /
  /+/
 / |
</pre>

</tr>

</table>

## <span style='color:orange'>_Describing where a train is on the line_</span>

The track "zero position" is defined as the leftmost piece of track of the top row.

Other <u>track positions</u> are just distances from this _zero position_ (following the line beginning clockwise).

A <u>train position</u> is the track position of the train _engine_.

## <span style='color:orange'>_Stations_</span>

Train stations are represented by a letter `S`.

Stations can be on straight sections of track, or crossings, like this

<table>
<tr>
<td rowspan=2><i>Stations</i>
<td width = "20%">
<pre style='background:black'>

----S-----

</pre>
<td width = "20%">
<pre style='background:black'>
|
S
|
</pre>
<td width = "20%">
<pre style='background:black'>
\
 S
  \
</pre>
<td width = "20%">
<pre style='background:black'>
   /
  S
 /
</pre>
</tr>

<tr>
<td width = "20%">
<pre style='background:black'>
    |
----S----
    |
</pre>
<td width = "20%">
<pre style='background:black'>
 \ /
  S
 / \
</pre>
</tr>

</table>

<br/>
When a train arrives at a station it stops there for a period of time determined by the length of the train!

The time **T** that a train will remain at the station is same as the number of _carriages_ it has.

For example

- `bbbB` - will stop at a station for 3 time units
- `Aa` - will stop at a station for 1 time unit

Exception to the rule: The "Express" trains never stop at any station.

## <span style='color:orange'>_Collisions_</span>

There are lots of ways to crash trains. Here are a few of Blaine's favorites...

- _The Chicken-Run_ - Train chicken. Maximum impact.
- _The T-Bone_ - Two trains and one crossing
- _The Self-Destruct_ - Nobody else to blame here
- _The Cabooser_ - Run up the tail of a stopped train
- _The Kamikaze_ - Crash head-on into a stopped train

# <span style='color:orange'>Kata Task</span>

Blaine has a variety of _continuous loop_ train lines.

Two trains are then placed onto the line, and both start moving at the same time.

How long (how many iterations) before the trains collide?

## <span style='color:orange'>_Input_</span>

- `track` - string representation of the entire train line (`\n` separators - maybe jagged, maybe not trailing)
- `a` - train A
- `aPos` - train A start position
- `b` - train B
- `bPos` - train B start position
- `limit` - how long before Blaine tires of waiting for a crash and gives up

## <span style='color:orange'>_Output_</span>

- Return how long before the trains collide, or
- Return `-1` if they have not crashed before `limit` time has elapsed, or
- Return `0` if the trains were already crashed in their start positions. Blaine is sneaky sometimes.

# <span style='color:orange'>Notes</span>

Trains

- Speed...
- All trains (even the "Express" ones) move at the same constant speed of 1 track piece / time unit
- Length...
- Trains can be any length, but there will always be at least one carriage
- Stations...
- Suburban trains stop at every station
- "Express" trains don't stop at any station
- If the start position happens to be at a station then the train leaves at the next move
- Directions...
- Trains can travel in either direction
- A train that looks like `zzzzzZ` is travelling _clockwise_ as it passed the track "zero position"
- A train that looks like `Zzzzzz` is traveliing _anti-clockwise_ as it passes the track "zero position"

Tracks

- All tracks are single continuous loops
- There are no ambiguous corners / junctions in Blaine's track layouts

All input is valid

# <span style='color:orange'>Example</span>

In the following track layout:

- The "zero position" is <span style='background:orange'>/</span>
- Train A is <span style='background:green'>Aaaa</span> and is at position `147`
- Train B is <span style='background:red'>Bbbbbbbbbbb</span> and is at position `288`
- There are 3 stations denoted by `S`

<pre style='background:black'>
                                <span style='background:orange'>/</span>------------\
/-----<span style='background:green'>Aaaa</span>----\                /             |
|             |               /              S
|             |              /               |
|        /----+--------------+------\        |
\       /     |              |      |        |
 \      |     \              |      |        |
 |      |      \-------------+------+--------+---\
 |      |                    |      |        |   |
 \------+------S-------------+------/        /   |
        |                    |              /    |
        \--------------------+-------------/     |
                             |                   |
/-------------\              |                   |
|             |              |             /-----+----\
|             |              |             |     |     \
\-------------+--------------+-----S-------+-----/      \
              |              |             |             \
              |              |             |             |
              |              \-------------+-------------/
              |                            |
              \---------<span style='background:red'>Bbbbbbbbbbb</span>--------/
</pre>

<br>
<hr>
Good Luck!

DM<br><span style='color:red'>:-)</span>
