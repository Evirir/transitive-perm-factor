from typing import List, Tuple


def is_transitive(n, factors):
    return Graph([list(range(n)), factors]).is_connected()


def change_index_start(target, allowed_pairs, start_index=1):
    """Reduce all numbers in target and allowed_pairs by start_index."""
    for index, ele in enumerate(target):
        target[index] = ele - start_index
    for index, (u, v) in enumerate(allowed_pairs):
        allowed_pairs[index] = (u - start_index, v - start_index)


def get_min_transitive_factorizations(
        target: List[int],
        allowed_pairs: List[Tuple[int, int]]) -> Tuple[int, List[List[Tuple[int, int]]]]:
    """Find the list of minimal transitive factorizations of target using only the
    transpositions in allowed_pairs.

    target and allowed_pairs are 0-indexed. Use change_index_start for changing the
    starting index.

    Returns:
        (min length, list of minimal transitive factorizations) (int, List[List[Tuple[int, int]]])
        Returns (0, []) instead if the given pairs do not connect [n].
    """
    n = len(target)  # permutation size

    if not is_transitive(n, allowed_pairs):
        return (0, [])

    generator = RecursivelyEnumeratedSet(
        [[]],
        lambda fact: [
            fact + [x] for x in allowed_pairs if len(fact) == 0 or x != fact[-1]],
        structure='forest')
    generator_it = generator.breadth_first_search_iterator()

    min_length = -1  # -1 if not found yet
    factorizations = []
    while True:
        factors = next(generator_it)
        if min_length != -1 and len(factors) > min_length:
            break
        if not is_transitive(n, factors):
            continue
        min_length = len(factors)
        factorizations.append(factors)

    return min_length, factorizations


def main():
    allowed_pairs = [(1, 2), (2, 5), (3, 5), (4, 3)]
    target = [5, 3, 2, 4, 1]
    change_index_start(target, allowed_pairs)

    min_length, min_facts = get_min_transitive_factorizations(target, allowed_pairs)
    if min_facts[0] == 0:
        print(f"Given transpositions do not connect [{len(target)}].")
    else:
        print(f"Min length: {min_length}")
        print("List of minimal transitive factorizations:")
        for index, factors in enumerate(min_facts):
            min_facts[index] = [(u + 1, v + 1) for (u, v) in factors]
        for factors in min_facts:
            print(' '.join([str(factor) for factor in factors]))


if __name__ == '__main__':
    main()
