:- module generic.

:- interface.
:- import_module float, uint8, uint16, int16, int.

:- typeclass convert(A,B) where [
    func convert(A) = B
].

:- typeclass bounded(A) where [
    func min_bound = A,
    func max_bound = A
].

:- instance bounded(uint8).
:- instance bounded(uint16).
:- instance bounded(int16).
:- instance bounded(int).

:- instance convert(uint8,  float).
:- instance convert(uint16, float).
:- instance convert(int16,  float).
:- instance convert(float, float).
:- instance convert(int, float).
:- instance convert(float, uint8).


:- func proportionally_convert(A) = B <= (bounded(A), bounded(B), convert(A,float), convert(B, float), convert(float, B)).

:- implementation.
:- import_module std_util.

proportionally_convert(A) = Result :- (
    Result = convert(
        convert(MinB) + 
        (convert(A) - convert(MinA)) /
        (convert(MaxA) - convert(MinA)) *
        (convert(MaxB) - convert(MinB))
    ),
    MinA = min_bound `with_type` A,
    MaxA = max_bound `with_type` A,
    MinB = min_bound `with_type` B,
    MaxB = max_bound `with_type` B
    ).

:- instance bounded(uint8) where [
    min_bound = 0u8,
    max_bound = 255u8
].

:- instance bounded(uint16) where [
    min_bound = 0u16,
    max_bound = 65535u16
].

:- instance bounded(int16) where [
    min_bound = -32768i16,
    max_bound = 32767i16
].

:- instance bounded(int) where [
    min_bound = min_int,
    max_bound = max_int
].

:- instance convert(uint8, float) where [
    convert(U) = float.from_uint8(U)
].
:- instance convert(uint16, float) where [
    convert(U) = float.from_uint16(U)
].
:- instance convert(int16, float) where [
    convert(U) = float.from_int16(U)
].
:- instance convert(float, float) where [
    func(convert/1) is id
].

:- instance convert(int, float) where [
    func(convert/1) is float
].

:- instance convert(float, uint8) where [
    convert(F) = uint8.det_from_int(float.round_to_int(F))
].