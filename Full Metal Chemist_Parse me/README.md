Source: [Codewars.com](https://www.codewars.com/kata/5a529cced8e145207e000010)

_Molecules are beautiful things. Especially organic ones..._

<br>
<hr>

# Overview

This time, you will be provided the name of a molecule as a string, and you'll have to convert it to the corresponding raw formula (as a dictionary/mapping).

### Input:

```
"5-methylhexan-2-ol"

    OH         CH3
    |          |        (the representation will be drawn in the console)
CH3-CH-CH2-CH2-CH-CH3
```

### Output:

```python
ParseHer("5-methylhexan-2-ol").parse() == {'C':7, 'H': 16, 'O': 1}
```

```java
new ParseHer("5-methylhexan-2-ol").parse();
Should be equal to the equivalent of that Map<String,Integer>: {"C":7, "H": 16, "O": 1}
```

```javascript
parse('5-methylhexan-2-ol') should be deep equal to {C:7, H: 16, O: 1}
```

<br>

To do that, you'll have to accomplish two tasks:

1. Find a way to properly tokenize and then parse the name of the molecule, using the provided information (_you'll have to find out the proper grammar, like I did_ ;-p ).
2. Then build the complete raw formula and return it as a dictionary (key: chemical symbol as a string, value: number of this chemical element in the molecule).

All inputs will be valid.

<br>

To help you in this task, several things are provided:

- No chemistry knowledge is required: you'll find all the needed information below. <font size="2" color="gray">(<i>Note: it's very long, yes, but a large majority of the strings needed are already provided in the solution setup, using different lists. Use them as you want</i> )</font>
- To build the raw formula, being a chemist might be of some help, but don't worry if you are not: you'll just have to identify the patterns through the different tests. They are specifically designed so that these patterns can be found easily. <font size="2" color="gray">(<i>Note: the related academical knowledge is about "degrees of insaturation" of the molecule, if you're interested in it. If you already know that, that will of course be of help, but if you do not, just focus yourself on the pattern recognition work, going through the sample tests, rather than trying to understand the notion with the wiki article (which is pretty bad about that </i>))</font>
- All the molecules will be drawn in the console (except for the random tests and the very last fixed tests), so that you can see what it is exactly. <font size="2" color="gray">(<i>Note: due to the need of escape characters</i> '\'<i> to represent some bounds, the strings in the example tests might not be very readable. Prefer to look at the version printed in the console</i> )</font>

<br>

### Specifications of the tests:

- 40 sample tests
- around 85 fixed tests
- 6000 random tests

<br>
<hr>
<br>

<div align="center"><font size=6 color="orange"><u><i>Nomenclature rules of organic compounds</i></u></font><br><font color="gray">(<i>Some of them, at least...</i>)</font></div>

<br>

Here is what you need to know about the nomenclature of organic compounds.

You'll actually get A LOT of information, here. Keep in mind that you'll get way more than what you actually need to solve the task, to ensure that you'll be able to find your way in the names if an assertion fails. So don't shy away just because of this... ;)

_You'll find several summaries of all the information at the end of the description, to help you to find your way in all of this.
And don't forget to read the very last section, well named_ "**the pins in the a\*\***", at the bottom of the description.\_

<br>

<font color="gray"><i>
<u>Notes to the chemists or those who bother:</u><ul>

<li>The names you'll encounter will always be "well formed", but they won't always be "the good one", especially in the random tests. Meaning, they will always represent an actual molecule/be parsable applying the rules below, but they could not be the real name for that molecule (for example: incorrect choice of the main chain, inversion of the numbering of the positions, ...). Those who know a bit about nomenclature could see them. For the others, don't bother with that, just apply the given rules ;)
<li> To make the task manageable, having more consistent strings for the names, the positions  of the groups/ramifications will be written following the way of the French nomenclature where the position is right on...the left... </i> XD <i>of the related part. Meaning, expect "butan-2-ol" instead of "2-butanol", and so on.
</ul>
</i></font>

<br>
<br>

<font size=6 color="orange"><b><i>Alkanes</i></b></font>

<br>

- <font size=5 color="orange"><b><i>Linear alkanes</i></b></font>

The name of linear molecules, such as in the examples below, are simply given by a "radical" representing their number of carbons, followed by the suffix `ane`:

`radical + "ane"`

```
methane = meth + ane = 1 carbon   ->  CH4
ethane  = eth + ane  = 2 carbons  ->  CH3-CH3
propane = ...                     ->  CH3-CH2-CH3
butane  = ...                     ->  CH3-CH2-CH2-CH3
...

RADICALS = ["meth",  "eth",   "prop",   "but",      "pent",     "hex",     "hept",     "oct",     "non",    "dec",
            "undec", "dodec", "tridec", "tetradec", "pentadec", "hexadec", "heptadec", "octadec", "nonadec"]
```

You'll find the `RADICALS` list (up to 19 carbons) in the solution setup.

<br>

- <font size=5 color="orange"><b><i>Ramified alkanes</i></b></font>

If the molecule isn't linear, you can name it by picking a main chain, then add `alkyls` groups at the beginning of the name. You don't have to worry about the way the main chain is chosen or the way the numbering is done.

Alkyls groups are defined this way:

`positions + "-" + multiplier + radical + "yl"` (where the positions are numbers joined by commas ; multipliers are explained just after)

```
CH3-CH-CH2-CH3    -> main chain: like "butane"
    |
    CH3           -> alkyl: like "methane", at position 2 (on the main chain) => "2-methyl"
                             (no multiplier since you have only one methyl group)
    => 2-methylbutane
```

<br>

- <font size=5 color="orange"><b><i>Several ramifications: multipliers</i></b></font>

When you have several times the same alkyl group at different places, you add a multiplier:

```
CH3-CH-CH-CH2-CH-CH3    => 2,3,5-trimethylhexane
    |  |      |                  ^^^
  CH3  CH3    CH3

CH3-CH-CH-CH2-CH-CH3    => 3-ethyl-2,5-dimethylhexane
    |  |      |                        ^^
  CH3  CH2    CH3
       |
       CH3
```

You do not need to know about the order of the alkyls in the name.
Here is the complete list of multipliers (from 2 to 19, provided in the solution setup):

```
MULTIPLIERS = [         "di",     "tri",     "tetra",     "penta",     "hexa",     "hepta",     "octa",     "nona",     "deca",
              "undeca", "dodeca", "trideca", "tetradeca", "pentadeca", "hexadeca", "heptadeca", "octadeca", "nonadeca"]
```

<br>
<br>

<font size=6 color="orange"><b><i>Cycles</i></b></font>

<br>

When a chain or a group has a cyclic shape, you just add the `cyclo` prefix before the radical part (both for the main chain or alkyls):

```
CH2-CH2
|   |                                => cyclobutane
CH2-CH2

CH3-CH-CH2-CH2-CH2-CH2-CH-CH3
    |                  |
    CH                 CH           => 2,7-dicyclobutyloctane
   / \                / \                    ^^^^^
H2C   CH2          H2C   CH2
   \ /                \ /
    CH2                CH2

```

The `"cyclo"` prefix is considered as part of the radical it is "applied" to. So in case of ramifications, the order of the different parts of the name is:

```
CH2-CH-CH2-CH3                 The main chain being the cyclic one:
|   |                                => 1-ethylcyclobutane
CH2-CH2                                        ^^^^^

```

<br>
<br>

<font size=6 color="orange"><b><i>Alkenes & alkynes</i></b></font>

<br>

- **alkene:** double bound between carbons. Replace the suffix `ane` by `"-" + positions + "-" + multiplier + "ene"` (only the position of the first carbon holding a double bound is given)
- **alkyne:** triple bound between carbons. Replace the suffix `ane` by `"-" + positions + "-" + multiplier + "yne"` (only the position of the first carbon holding a triple bound is given)
- If you have both alkenes and alkynes in the molecule, you replace `ane` with `...en...yne` (double bounds always come first)

```
CH3-CH=CH-CH2-CH2-CH3    =>  hex-2-ene
CH3-CH=CH-CH2-CH=CH2     =>  hex-1,4-diene (warning: the numbering is reversed, here)

CH3-C{=}C-CH2-CH2-CH3    =>  hex-2-yne  ('{=}' used to represent the three bounds)
```

You can mix up the things...:

```
CH3-C{=}C-CH=CH-C{=}C-C{=}C-CH=CH-CH2-CH3

    => tridec-4,10-dien-2,6,8-triyne
```

...or even find those in the alkyl groups:

```
CH3-C{=}C-CH-C{=}C-CH2-CH2-CH=CH-CH3    ->  main chain
          |
          CH2-CH=CH-CH=CH-CH2-CH3       ->  ramification (note: position 1 is always the C bounded to the main chain)

    => 4-hept-2,4-dienylundec-9-en-2,5-diyne
```

<br>
<br>

<font size=6 color="orange"><b><i>Ramifications of ramifications</i></b></font>

<br>

Here comes the "funny" work... If a ramification itself is ramified, same rules as above are applied. But to identify the lower level, squared brackets are used around the prefix of lower level, this part being put just before the radical part of the alkyl group at the current level...
Well, an example might be better:

`positions + "-" + multiplier + "[" + subramification + "]" + radical + "yl"`

Examples:

```
No subramifications:

    CH2-CH-CH2-CH2-CH2-CH2-CH2-CH2-CH3     => 1-heptylcyclobutane
    |   |
    CH2-CH2

With subramifications:

                   CH2-CH2-CH3
                   |
    CH2-CH-CH2-CH2-CH-CH2-CH2-CH2-CH3      => 1-[3-propyl]heptylcyclobutane
    |   |
    CH2-CH2

                   CH2-CH2-CH3
                   |
    CH2-CH-CH2-CH2-CH-CH2-CH2-CH2-CH3
    |   |                                  => 1,2-di[3-propyl]heptylcyclobutane
    CH2-CH-CH2-CH2-CH-CH2-CH2-CH2-CH3
                   |                          (Note here: "1,2-di" applies to the whole "[3-propyl]heptyl" part)
                   CH2-CH2-CH3
```

This goes recursively at any depth:

```
           CH3        CH3
           |          |
           CH2    CH2-CH-CH3
           |      |
    CH2-CH-CH-CH2-CH-CH2-CH2-CH2-CH3
    |   |                                  => 1,2-di[1-ethyl-3-[2-methyl]propyl]heptylcyclobutane
    CH2-CH-CH-CH2-CH-CH2-CH2-CH2-CH3
           |      |
           CH2    CH2-CH-CH3
           |          |
           CH3        CH3
```

<br>
<br>

<font size=6 color="orange"><b><i>Functions</i></b></font>

<br>

On the top of that, you can have "functional groups" in the molecule. Such as alcohols, esters, carboxylic acids, and so on.
Basically, you can find those functional group at two different places:

- <u>At the very end of the name, as suffix:</u> Then, this is called the "main function". The ending `e` of the name is replaced by the appropriate `positions + "-" + multiplier + suffix` corresponding to the function.
- <u>Amongst the prefixes of the related carbon chain:</u> It then behaves in the same manner than the alkyl groups: `positions + "-" + multiplier + prefix`, except that most of those functional groups cannot have subramifications (generally... there are some exceptions, see details below).

Note that for a same type of functional group, prefix(es) and suffix names are different _<font size=2 color="gray">(The reason of these two naming is that only one type of function can be used as suffix (we won’t see how/why), so all the other ones of the molecule have to show up as prefixes)</font>_.

You may find below the information relative to all the functional groups used in the kata.

<br>
<br>

## **_Simple functions_**

<br>

- <font color="orange"><b><i><u>Halogens:</u></i></b></font> always used as prefixes.

```
  F   ->   prefix = "fluoro"
  Cl  ->   prefix = "chloro"
  Br  ->   prefix = "bromo"
  I   ->   prefix = "iodo"

  CH3-CH2-CH2-CH2-CH2-F      ->     "1-fluoropentane"

  CH3-CH-CH2-CH2-CH3         ->     "2-chloropentane"
      |
      Cl

  CH3-CH-CH2-CH2-CHBr2        ->     "1,1-dibromo-4-chloropentane"
      |
      Cl
```

<br>

- <font color="orange"><b><i><u>Alcohols:</u></i></b></font>

```
  OH  ->   prefix = "hydroxy"
           suffix = "ol"

      OH
      |
  CH3-CH-CH2-CH2-CH3         ->     "pentan-2-ol"

     HO  CH2-OH
      |  |
  CH3-CH-CH-CH2-CH2-OH       ->     "3-[1-hydroxy]methylpentan-1,4-diol"
```

<br>

- <font color="orange"><b><i><u>Thiols:</u></i></b></font>

```
  SH   ->   prefix = "mercapto"
            suffix = "thiol"

      SH
      |
  CH3-CH-CH2-CH2-CH3         ->     "pentan-2-thiol"

     HO  CH2-CH2-SH
      |  |
  CH3-CH-CH-CH2-CH2-OH       ->     "3-[2-mercapto]ethylpentan-1,4-diol"
```

<br>

- <font color="orange"><b><i><u>Imines:</u></i></b></font>

```
  =NH  ->   prefix = "imino"
            suffix = "imine"

  H3C-CH2-CH2-C-CH3
              ||          ->     "pentan-2-imine"
              NH

          OH
          |
  H3C-CH2-CH-C-CH3
             ||          ->     "2-iminopentan-3-ol"
             NH

(Note: in this kata, the nitrogen of an imine will never hold a carboned chain, even if it could be possible)
```

<br>
<br>

## **_A bit less simple functions_**

<br>

- <font color="orange"><b><i><u>Ketones:</u></i></b></font> They can never be on an extremity of a chain.

```
  =O    ->    prefix = "oxo"
              suffix = "one"

      O
      ||                ->    "pentan-2-one"
  CH3-C-CH2-CH2-CH3

            CH3
            |
  H3C   CH2-C=O         ->     "4-[1-oxo]ethylheptan-2,6-dione"
     \  |
      C-CH-CH2-C-CH3           (note that the ethyl ramification is the
    //         ||               chain of 2 carbons on the very left, here)
   O           O
```

<br>

- <font color="orange"><b><i><u>Aldehydes:</u></i></b></font> Like ketones, but only present on an extremity.

The aldehydes are a bit special about two points:

1. Their prefix: until now, prefixes and suffixes represented always the exact same thing. For the aldehydes, the prefix represents the same kind of functional group, but it holds an extra carbon and its hydrogen. See examples below.
1. Since they always are at an extremity, one are not forced to give their position, when used as suffixes (you can consider this as an _elision:_ see the last part of the description). For the prefix version, one still needs it since the "carbon at the extremity" is already in the `formyl` group and so, it can be anywhere in the molecule.

```
  -CH=O   ->    prefix = "formyl"  (anywhere on a chain)
     =O   ->    suffix = "al"      (as ketones, but only at an extremity)


      CH3-CH2-CH2-CH2-CH=O      ->     "pentanal"

             CH2-CH2-CH=O
             |
      HC-CH2-CH-CH2-CH2-CH=O    ->     "4-[1-formyl]methylheptandial"
     //
    O
          Note about this last example:
            - The ramification still is the leftmost part (O=CH-CH2-...),
              but since the formyl group holds the last carbon, the radical
              used for the ramification has only 1 carbon left and is "methyl".
            - No positional information for the suffixes, but present for the
              prefix if no elision (see last section).
```

<br>

- <font color="orange"><b><i><u>Carboxylic acids:</u></i></b></font> They behave a bit like the aldehydes, having prefix and suffixes that represent the same functional group, but with 1 extra carbon in some cases. Positions are generally omitted when using suffixes too (same as for the aldehydes).

```
  Suffix type 1:  "oic acid"   (note the presence of the space character).

       OH                          OH                 "ethanoic acid"
       |          example:         |                  (the carbon of the function is in the main chain)
  ...-(C)=O                    H3C-C=O



  Suffix type 2:  "carboxylic acid" (used in some special cases.  Don't bother with the how and the why)

      OH                           OH             ->  "methancarboxylic acid"
      |           example:         |                   ^^^^
  ...-C=O                      H3C-C=O               (which is incorrect, but will show you that
                                                     the carbon of the function isn't considered
                                                     as a part of the main chain, here)

  Prefix:         "carboxy"                OH
                                           |      ->  "4-carboxyheptan-1,7-dioic acid"
      OH                           CH2-CH2-C=O
      |           example:          |                 (for this time, let's do this with the positions... ;) )
  ...-C=O                     HO-C-CH-CH2-CH2-C=O
                                //            |
                               O              OH
```

<br>

- <font color="orange"><b><i><u>Amides:</u></i></b></font>

We will use simple cases only, for the amides, here: their nitrogen atom will never hold a carboned chain.
Amides are always at an extremity of a chain.

```
       NH2        Suffix:   "amide"
       |          Prefix:   "amido"
  ...-(C)=O


    H2N-CH=O                ->    "methanamide"

    O=C-CH2-CH=CH-CH3       ->    "pent-3-enamide"
      |
      NH2

    O=C-CH2-CH2-CH2-C=O     ->    "5-amidopentanoic acid"
      |             |
      NH2           OH

Note that the carbon isn't part of the function, but is part of the radical.
```

<br>
<br>

## **_Complex cases_**

<br>

The following cases all need auxiliary chains or present some weird behaviors.

 <br>

- <font color="orange"><b><i><u>Amines, phosphines, arsines:</u></i></b></font>

Those three have the same behavior and a strong particularity: they can be used with two different kinds of nomenclatures, and can hold zero or more carboned chains. Let's review this in details...

```
As suffixes:  "amine", "phosphine", "arsine"


  * WAY 1:    The function itself is considered as the main chain, and all carboned chains
  --------    (up to three of them) around are alkyls.

  * WAY 2:    Not the general case, but they can be used the same way than the previous functions.
  --------

Examples:                   WAY 1                        WAY 2

    H3C-NH2           "methylamine"                "methan-1-amine"
    H3C-PH2           "methylphosphine"            "methan-1-phosphine"
    H3C-AsH2          "methylarsine"               "methan-1-arsine"

    H3C-N-CH2-CH3     "ethyldimethylamine"         "ethan-1-[dimethyl]amine"
        |
        CH3


Way 2 is actually used in this type of cases:

    H2N-H2C-CH2-CH2-CH2-CH2-CH2-NH2        hexan-1,6-diamine    (the "cadavérine", in French...
                                                                 What a beautiful name... ;p )
```

Prefixes, on the other side, behaves in the "usual" way only, except that the functions can hold subramifications.

```
Prefixes:    "amino", "phosphino", "arsino"

                OH
                |                            ->    "1,6-diaminohexan-3-ol"
    H2N-H2C-CH2-CH-CH2-CH2-CH2-NH2

                OH
                |                            ->    "1-amino-6-[diethyl]arsinohexan-3-ol"
    H2N-H2C-CH2-CH-CH2-CH2-CH2-As-CH2-CH3
                               |                  (there are no position to give for the ethyl groups
                               CH2-CH3             since they are bound to the arsenic atom, not to a chain)

```

<br>

- <font color="orange"><b><i><u>Ethers:</u></i></b></font>

They have a lot in common with the previous ones, but there is only the "way 1" for the suffix. So, no main chain, and (always) two alkyls since ethers are made with oxygen.

```
As suffix:    "alkylether"

Examples:      H3C-CH2-O-CH2-CH3         "diethylether"

               H3C-O-CH=CH-CH3           "methylprop-1-enylether"


Prefix:    "alkoxy"

Examples:      H3C-O-CH2-CH2-CH2-OH      "3-methoxypropan-1-ol"
               ^^^^^                        ^^^^^^^

    Note that the radical is use "raw".
    Though, if a multiple bound was in the auxiliary chain:

        H2C=CH-CH2-O-CH2-CH2-CH2-OH      "3-prop-2-enoxypropan-1-ol"
```

<br>

- <font color="orange"><b><i><u>Esters:</u></i></b></font>

They need an auxiliary carboned chain (alkyl). Their general form as suffix is:

Suffix: `alkyl alkanoate`

```
       O
       ||         Main chain, as "alkan":        the one beginning with the "(C)", in between the two oxygens.
  ...-(C)-O-R     Auxiliary chain, as "alkyl":   the "R", separated from the main chain by the oxygen.
```

Note that:

- The carbon of the main chain is... part of the main chain, not of the function.
- Here, you have to deal with two separated words again.

Examples:

```
      O
      ||                                ->   "propyl ethanoate"
  CH3-C-O-CH2-CH2-CH3

        O
       ||                               ->   "methyl butanoate"
  CH3-O-C-CH2-CH2-CH3

                        O
                        ||              ->   "eth-1-enyl hept-2-enoate"
  CH3-CH2-CH2-CH2-CH=CH-C-O-CH=CH2
```

Due to their structure, esters as prefixes can be in two different form:

Prefix type 1: `alkoxycarbonyl`

```
      O
      ||         Main chain, as "...":       the carbon of the function is NOT part of the main chain.
  ...-C-O-R      Auxiliary chain, as "alk":  the "R", separated by the oxygen.

Example:
             CH3                                vvvvvvvvvvvvvv
 vvvvvvvvvvv |                          ->   "4-ethoxycarbonylpentanoic acid"
 CH3-CH2-O-C-CH-CH2-CH2-C=O
          ||            |                     (note the absence of squared brackets, here
           O            OH                     and the lack of "yl" in the auxiliary chain)
```

Prefix type 2: `alkanoyloxy...`

```
         O
        ||        Main chain, as "...".
  ...-O-(C)-R     Auxiliary chain, as "alkan":  the "R", WITH the carbon in between the two oxygens

Example:
             CH3                                vvvvvvvvvvvv
 vvvvvvvvvvv |                          ->   "4-propanoyloxypentanoic acid"
 CH3-CH2-C-O-CH-CH2-CH2-C=O
        ||              |
         O              OH                    (note the absence of squared brackets, again)

  Put a double bound in the auxiliary chain and with this prefix, it would become ""prop-2-enoyloxy..."
```

<br>

- <font color="orange"><b><i><u>Aromatic cycles:</u></i></b></font>

These are actually a special kind of radicals. We will focus our effort on only one simple case: the benzene.

```
* Used as main chain:    "benzene", C6Hx  (base: C6H6, less H if substituted)

        HC-CH
       //   \\
      HC     CH        It can of course hold ramifications and functions.
        \   /
        HC=CH

             CH2-CH3
            /
        HC-C
       //   \\
      HC     C-CH=O      ->    "2-ethyl-1-formylbenzene"
        \   /
        HC=CH


* Used as ramification:    "phenyl", C6H5

        HC-CH                  OH
       //   \\                 |
      HC     C-CH2-CH2-CH2-CH2-C=O      ->   "5-phenylpentanoic acid"
        \   /
        HC=CH

    Note: we won't use any substituted phenyl.
```

_<font color="gray" size=2><u>To the chemists:</u> to keep the things simpler, we won't consider cases like phenol, benzoyl, ... A phenol, if it should occur, would be called "benzenol" instead, and so on.</font>_

<br>
<br>
<br>

<font size=6 color="orange"><b><i>Summaries</i></b></font>

<br>

- ## _General form of a name_

So, **_out of some exceptions_**, the name of an organic compound can be seen as something like that:

`[[...]subparts]prefixes + radical + suffixes`

With:

```
  suffixes  = alkenes, alkynes, functional groups
  prefixes  = functional groups (as prefixes), subchains, "cyclo"

  subchains =  [other prefixes] + (cyclo) + radical + (alkenes or alkynes) + "yl"
            or functional groups as prefixes
  subparts  = subchains
```

_<font color="gray">Note: this is NOT a reliable BNF diagram but only some sort of helper around which I hope you'll be able to gather your thoughts.</font>_

<br>

- ## _Radicals and multipliers_

```
Number     Radical     Multiplier
------     -------     ----------
   #1       meth        /
   #2       eth         di
   #3       prop        tri
   #4       but         tetra
   #6       pent        penta
   #6       hex         hexa
   #7       hept        hepta
   #8       oct         octa
   #9       non         nona
   #10      dec         deca
   #11      undec       undeca
   #12      dodec       dodeca
   #13      tridec      trideca
   #14      tetradec    tetradeca
   #15      pentadec    pentadeca
   #16      hexadec     hexadeca
   #17      heptadec    heptadeca
   #18      octadec     octadeca
   #19      nonadec     nonadeca
```

<br>

- ## _Miscellaneous_

```
Alkanes        ane
Alkenes        ene
Alkynes        yne
Alkyls         yl
Cycles         cyclo
```

<br>

- ## _Functional groups_

```
Note about the "Chemical group" representations:
    * When you see "(C)", that means the carbon is already counted in the main chain:
      you do not have to add a new one to build the function.
    * Warning with the representations of carboxylic acids, amides or esters:
      be aware of the double bound with one of the "O" (see details upper)


Functional group      Prefix              Suffix              Chemical group      Notes
----------------      ------              ------              --------------      -----

halogens              fluoro              .                   ...-F
                      chloro              .                   ...-Cl
                      bromo               .                   ...-Br
                      iodo                .                   ...-I

alcohol               hydroxy             ol                  ...-OH

thiol                 mercapto            thiol               ...-SH

ketone                oxo                 one                 ...(C)=O            Never at an extremity of the chain
aldehyde              .                   al                  ...(C)H=O           Only at an extremity of the main chain
                      formyl              .                   ...CH=O             1 extra carbon, here!

carboxylic acid       .                   oic acid            ...(C)O-OH          Only at an extremity of the main chain
                      .                   carboxylic acid     ...-CO-OH           1 extra carbon, here!
                      carboxy             .                   ...-CO-OH           1 extra carbon, here!

ester                 .                   (alkyl) ...oate     ...(C)O-O-R         R being a secondary alkyl chain (see details above). Only at an extremity of the main chain
                      (alk)oxycarbonyl    .                   ...(C)-CO-O-R       Anywhere on the chain. R being a secondary alkyl chain (see details above)
                      (alkan)oyloxy       .                   ...(C)-O-OR         Anywhere on the chain. R being a secondary alkyl chain (see details above)

ether                 (alk)oxy            (alkyles)ether      R1-O-R2             R1 and R2 being alkyles if suffix, or R2 being the main chain if prefix (see details above)

amine                 (alkyles)amino      amine               N  (various)        See details above about the different possibilities
amide                 amido               amide               ...(C)O-NH2         Only at an extremity
imine                 imino               imine               ...(C)=NH

arsine                (alkyles)arsino     (alkyles)arsine     As (various)        See details above about the different possibilities
phosphine             (alkyles)phosphino  (alkyles)phosphine  P  (various)        See details above about the different possibilities

aromatic cycle        .                   benzene             C6Hx (various)      See details above about the different possibilities
                      phenyl              .                   ...-C6H5
```

<br>

- ## _Valence number of all the atoms involved_

The valence number is the number of bounds (understood as number of strokes going away from the atom) that this chemical element makes with other atoms. Any atom has to hold this exact number in any molecule.

```
  1  |  2  |  3  |  4
-----|-----|-----|-----
  Br |  O  |  As |  C
  Cl |  S  |  N  |
  F  |     |  P  |
  H  |     |     |
  I  |     |     |
```

<br>
<br>

<font size=5 color="orange"><b><i>The "pinS in the a\*\*" section...</i></b></font>

<br>

Well, yes...
Sadly, you're not completely done with it yet...

<br>

- ## _Elisions of some positions_

Chemists are clearly not computer guys (or at least, those who established the rules of nomenclature).
That means... It happens a lot that they suppress some tiny parts of a name if they think about those as not meaningful or cumbersome ones, or even add some if they find that more beautiful or hearable or...
For our own sake, we will manage only one of those cases: the elision of the positions of groups or functions on the first carbon of a chain (but exclusively present at this position):

    "cyclobutan-1-ol"        =>   "cyclobutanol"
    "cyclobutan-1,1-diol"    =>   "cyclobutandiol"

    "cyclobutan-1,2-diol"    =>   "cyclobutan-1,2-diol"  (no elision because not only "one(s)", here)

Note that elision is not systematic, so your code will have to manage both cases.
Elision can of course be applied to any kind of part of the name that requires a position number, like in `"chlorocyclobutane"`, for example.

<br>

- ## _Ambiguous matches when parsing the name of a molecule_

If you encounter some ambiguous cases that aren't clearly identifiable, assume you get the longest possible chain name. But ONLY if the match is ambiguous!
Some examples:

    "2,3,5-tridecyl"  =>   NOT ambiguous: this is three "decyl" chains
    "2-tridecyl"      =>   NOT ambiguous: this is one "tridecyl" at position 2
    "tridecylamine"   =>   AMBIGUOUS, because the amine function could hold up to 3 chains, so assume it is one "tridecyl" chain

<br>

<hr>
<br>

<font size=4 color="orange"><b><i>Good <s>luck!!</s>... work!!</i></b></font>

<br>

[_The Full Metal Chemist collection_](https://www.codewars.com/collections/full-metal-chemist-collection)

<br>
