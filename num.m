:- module num.


:- interface.

:- import_module integer, rational.

:- typeclass num(T) where [
    func T + T = T,
    func T - T = T,
    func T * T = T,
    func negate(T) = T,
    func abs = T,
    func sign = T,
    func from_int(integer) = T
].

:- typeclass fractional(T) <= num(T) where [
    func T / T = T,
    func recip(T) = T,
    from_rational(rational) = T
].

