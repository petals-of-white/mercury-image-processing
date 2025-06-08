:- module generic.

:- interface.
:- import_module float, uint8, uint16, int8, int16, int.

:- module float.
:- interface.

:- func to_int8(float) = int8.
:- func to_int16(float) = int16.
:- func to_uint8(float) = uint8.
:- func to_uint16(float) = uint16.
:- end_module float.

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
:- instance bounded(int8).

:- instance convert(uint8,  float).
:- instance convert(uint16, float).
:- instance convert(int8,  float).
:- instance convert(int16,  float).
:- instance convert(float, float).
:- instance convert(int, float).
:- instance convert(float, uint8).
:- instance convert(float, int8).
:- instance convert(float, int16).
:- instance convert(float, uint16).

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

:- instance bounded(int8) where [
    min_bound = min_int8,
    max_bound = max_int8
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
:- instance convert(int8,  float) where[
    convert(U) = float.from_int8(U)
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

:- instance convert(float, int8) where [
    convert(F) = int8.det_from_int(float.round_to_int(F))
].

:- instance convert(float, int16) where [
    convert(F) = int16.det_from_int(float.round_to_int(F))
].

:- instance convert(float, uint16) where [
    convert(F) = uint16.det_from_int(float.round_to_int(F))
].

:- module float.
:- implementation.

to_int8(F) = int8.cast_from_int(float.ceiling_to_int(F)).
to_int16(F) = int16.cast_from_int(float.ceiling_to_int(F)).
to_uint8(F) = uint8.cast_from_int(float.ceiling_to_int(F)).
to_uint16(F) = uint16.cast_from_int(float.ceiling_to_int(F)).
:- end_module float.

:- end_module generic.