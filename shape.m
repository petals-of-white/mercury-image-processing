:- module shape.

:- interface.

:- type size    ---> size(width::int, height::int).
:- type point2d  ---> point2d(x::int, y::int).

:- func flat_size(size) = int.

:- implementation.
:- import_module int.
flat_size(size(Width, Height)) = Width*Height.

