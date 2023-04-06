def get_min_transitive_factorizations(n, allowed_pairs):
    generator = RecursivelyEnumeratedSet([[]],
                                         lambda fact: [
                                             fact + [x] for x in allowed_pairs if len(fact) == 0 or x != fact[-1]],
                                         structure='forest')
    it = generator.breadth_first_search_iterator()
    return [next(it) for _ in range(10)]

def main():
    n = 5
    allowed_pairs = [(1, 2), (2, 5), (3, 5)]
    min_facts = get_min_transitive_factorizations(n, allowed_pairs)
    print(min_facts)

if __name__ == '__main__':
    main()
