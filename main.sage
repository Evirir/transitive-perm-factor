"""Finds the minimal transitive factorization of a permutation given a set of allowed
transpositions. Prints the minimum length of the factorization, the number of such
factorizations, and the list of such factorizations.

Usage: sage main.sage [filepath]

Input file format:
[permutation]
[allowed pair 1]
[allowed pair 2]
...

Example: p = {1, 3, 4, 2}, allowed pairs = (1 2), (3 4), (4 2), (1 3)
Input file:
1 3 4 2
1 2
3 4
4 2
1 3
"""

import os
import sys
from typing import List, Tuple

FactorList = List[Tuple[int, int]]


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def usage():
    eprint("Usage: sage main.sage [filepath]")


def validate_pairs(n: int, allowed_pairs: FactorList):
    """Checks for invalid pairs, duplicate pairs (up to ordering), and self-loops."""
    elements = [u for pair in allowed_pairs for u in pair]
    assert 1 <= min(elements) and max(elements) <= n
    for (u, v) in allowed_pairs:
        assert u != v, f"Self-loop found: {(u, v)}"
    pairs = set([(min(u, v), max(u, v)) for (u, v) in allowed_pairs])
    assert len(pairs) == len(allowed_pairs), "Duplicate edge found."


def is_transitive(n, factors):
    return Graph([list(range(1, n + 1)), factors]).is_connected()


def change_index_start(target, allowed_pairs, start_index=1):
    """Reduce all numbers in target and allowed_pairs by start_index."""
    for index, ele in enumerate(target):
        target[index] = ele - start_index
    for index, (u, v) in enumerate(allowed_pairs):
        allowed_pairs[index] = (u - start_index, v - start_index)


def eval_factors(n: int, factors: FactorList):
    p = Permutations(n).identity()
    for factor in factors:
        p = p.left_action_product(Permutation(factor))
    return p


def get_min_transitive_factorizations(
        target: Permutation,
        allowed_pairs: FactorList) -> Tuple[int, List[FactorList]]:
    """Find the list of minimal transitive factorizations of target using only the
    transpositions in allowed_pairs.

    target and allowed_pairs are 1-indexed.

    Returns:
        (min length, list of minimal transitive factorizations) (int, List[FactorList])
        Returns (0, []) instead if the given pairs do not connect [n].
    """
    n = target.size()  # permutation size

    if not is_transitive(n, allowed_pairs):
        return (0, [])

    generator = RecursivelyEnumeratedSet(
        [[]],
        lambda fact: [fact + [x] for x in allowed_pairs],
        structure='forest')
    generator_it = generator.breadth_first_search_iterator()

    min_length = -1  # -1 if not found yet
    last_length = -1
    factorizations = []
    while True:
        factors = next(generator_it)
        if min_length != -1 and len(factors) > min_length:
            break

        if len(factors) > last_length:
            last_length = len(factors)
            print(f"Trying factorization length {len(factors)}")

        if not is_transitive(n, factors) or not eval_factors(n, factors) == target:
            continue
        min_length = len(factors)
        factorizations.append(factors)

    return min_length, factorizations


def read_file(filepath: str):
    """Reads the permutation and allowed transpositions from a file.
    Assume that filepath is a valid file path.

    File format:
    [permutation]
    [allowed pair 1]
    [allowed pair 2]
    ...

    Returns:
        (target, allowed_pairs) (List[int], FactorList)
    """
    with open(filepath, encoding='utf-8') as file:
        data = file.read()
        lines = data.strip().split('\n')

        target = map(int, lines[0].split())
        allowed_pairs = [tuple(map(int, line.split())) for line in lines[1:]]

        # Check transposition lines have 2 elements
        for index, pair in enumerate(allowed_pairs):
            assert len(pair) == 2,\
                f"Invalid transposition {pair} on line {index + 2}"

        return target, allowed_pairs


def main():
    if len(sys.argv) != 2:
        usage()
        return

    filepath = sys.argv[1]
    if not os.path.isfile(filepath):
        eprint(f"Invalid file path {filepath}")
        usage()
        return

    target, allowed_pairs = read_file(filepath)
    target = Permutation(target)
    n = target.size()
    validate_pairs(n, allowed_pairs)

    eprint("-----------------------------")
    eprint(f"target: {target}")
    eprint(f"allowed_pairs: {allowed_pairs}")

    min_length, min_facts = get_min_transitive_factorizations(
        target, allowed_pairs)
    eprint("-----------------------------")

    if min_length == 0:
        eprint(f"Given transpositions do not connect [{len(target)}].")
    else:
        print(f"Min length: {min_length}")
        print(f"Number of minimal transitive factorizations: {len(min_facts)}")
        for factors in min_facts:
            print(' '.join([str(factor) for factor in factors]))


if __name__ == '__main__':
    main()
