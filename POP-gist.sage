"""
A code snippet to accompany the paper: <insert link>

Code to check whether a finitely based permutation class is a POP class. 

Install (in a sage terminal):
    sage: pip install permuta

Note: you need to restart a sage terminal to use installed packages

Example:
    sage: load('POP-gist.sage')
    sage: basis = ((0, 1, 2, 3), (0, 3, 2, 1))
    sage: is_pop_class(basis)
    False
    sage: basis = ((0, 1, 2, 3),)
    sage: is_pop_class(basis)
    True
    sage: elms = [0,1,2,3]
    sage: rels = [[0, 1], [1, 2], [2, 3]]
    sage: poset = Poset([elms, rels])
    sage: pop_to_basis(poset)
    (Perm((0, 1, 2, 3)),)
    sage: rels = [[0, 1], [0, 2], [0, 3]]
    sage: poset = Poset([elms, rels])
    sage: pop_to_basis(poset)
    (Perm((0, 1, 2, 3)),
    Perm((0, 1, 3, 2)),
    Perm((0, 2, 1, 3)),
    Perm((0, 2, 3, 1)),
    Perm((0, 3, 1, 2)),
    Perm((0, 3, 2, 1)))
    sage: basis = ((0, 1, 2, 3),)
    sage: basis_to_pop(basis)
    Finite poset containing 4 elements
    sage: basis = ((0, 1, 2, 3), (0, 3, 2, 1))
    sage: basis_to_pop(basis)
    ValueError: Av(((0, 1, 2, 3), (0, 3, 2, 1))) is not a POP class. 

"""
from itertools import product
from typing import Tuple

from permuta import Perm

Basis = Tuple[Perm, ...]


def pop_to_basis(poset: Poset) -> Basis:
    """
    Return the basis that is implied by the labelled poset.

    Args:
        poset: a sage.combinat.posets.posets.Poset
               labelled with 0, ..., n

    Returns:
        a Tuple[Perm, ...] that is the basis implied by the poset
    """
    return tuple(sorted(map(Perm.inverse, poset.linear_extensions())))


def poset_intersection(poset: Poset, other: Poset) -> Poset:
    """
    Return the poset that comes from intersecting the relations.

    Args:
        poset: a sage.combinat.posets.posets.Poset
        other: a sage.combinat.posets.posets.Poset

    Returns:
        the sage.combinat.posets.posets.Poset that is the intersection
        of poset and other
    """

    return Poset(
        (
            range(min(len(poset), len(other))),
            set(map(tuple, poset.relations())).intersection(
                map(tuple, other.relations())
            ),
        )
    )


def perm_to_chain(perm) -> Poset:
    """
    Return the chain implied by a single perm.

    Args:
        perm: a permuta.Perm

    Returns:
        the sage.combinat.posets.posets.Poset that is the chain implied by
        the perm.
    """
    relations = [
        (idx1, idx2)
        for (idx1, val1), (idx2, val2) in product(enumerate(perm), enumerate(perm))
        if val1 < val2
    ]
    return Poset((range(len(perm)), relations))


def basis_to_pop(basis: Basis) -> Poset:
    """
    Return the intersection of the chains that each permutation
    in the basis implies. If Av(basis) is a POP class then this
    must be its associated poset (Theorem 1.1).

    Args:
        basis: an iterable of permuta.Perm

    Returns:
        the sage.combinat.posets.posets.Poset that is the
        interection of the chains in the basis

    Raises:
        ValueError: If Av(basis) is not a POP class
    """
    if basis:
        res = perm_to_chain(basis[0])
        for perm in basis[1:]:
            res = poset_intersection(res, perm_to_chain(perm))
        print(res, basis)
        if tuple(sorted(basis)) != pop_to_basis(res):
            raise ValueError(f"Av({basis}) is not a POP class. ")
        return res
    return Poset()


def is_pop_class(basis: Basis) -> bool:
    """
    Return True if a a basis can be defined as a POP.
    Theorem 1.1 says that if Av(basis) is a POP class then its
    associated poset is the intersection of the chains coming
    from the permutations in basis.

    Args:
        basis: a sorted tuple of permuta.Perm

    Returns:
        This returns True if Av(basis) is a POP class.
    """
    return tuple(sorted(pop_to_basis(basis_to_pop(basis)))) == tuple(sorted(basis))
