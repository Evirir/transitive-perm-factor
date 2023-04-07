# Minimal Transitive Factorization of Permutations

This code finds the minimal transitive factorization of a permutation given a set of allowed
transpositions. Prints the minimum length of the factorization, the number of such
factorizations, and the list of such factorizations.

## Usage

Run `sage main.sage [filepath]`, where `filepath` is the path to the input file.

## Input file format

```text
[permutation]
[allowed pair 1]
[allowed pair 2]
...
```

Example: $p = \{1, 3, 4, 2\}$, allowed transpositions = $(1\ 2), (3\ 4), (4\ 2), (1\ 3)$

Input file:

```text
1 3 4 2
1 2
3 4
4 2
1 3
```
