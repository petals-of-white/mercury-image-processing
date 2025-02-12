/*
    2D Image type based on mutable arrays. 
*/
:- module image.

:- interface.

:- import_module shape, list.

:- type image(T).

:- func map((func(A) = B), image(A)) = image(B).

:- pred get_pixel(image(T)::in, point2d::in, T::out) is semidet.

:- pred set_pixel(point2d::in, T::in, image(T)::di, image(T)::out) is semidet.

:- pred from_lists(list(list(T))::in, image(T)::out) is semidet.

:- pred minimum(image(T)::in, T::out) is semidet.

:- pred maximum(image(T)::in, T::out) is semidet.

:- implementation.

:- import_module array, int.

:- type image(T)    --->  image(array(T), size).

map(F, image(Arr, Size)) = OutputImg :-
    NewArr = array.map(F, Arr),
    OutputImg = image(NewArr, Size).

get_pixel(image(Arr, Size), Point, Pixel) :-
    LinearCoord = (Point^y * Size^height) + (Point^x),
    array.semidet_lookup(Arr, LinearCoord, Pixel).

set_pixel(Point, Pixel, InputImg, OutputImg) :-
    InputImg = image(InputArr, Size),
    LinearCoord = (Point^y * Size^height) + (Point^x),
    array.semidet_set(LinearCoord, Pixel, InputArr, OutputArr),
    OutputImg = image(OutputArr, Size).    


% Row major
from_lists([], Image) :- Image = image(make_empty_array, size(0,0)).
from_lists(Rows @ [FirstRow | _], Image) :-
    NumColumns = list.length(FirstRow),
    NumRows = list.length(Rows),
    ( if
        all [Row] (
            list.member(Row, Rows)
        =>
            list.length(Row) = NumColumns
        )
    then
        Arr = array(list.condense(Rows)),
        Image = image(Arr, size(NumColumns, NumRows))
    else
        fail
    ).

minimum(image(Arr, _), Min) :-
    array.size(Arr) \= 0,
    Min = array.foldl(func(X,Y) = (if X @< Y then X else Y), Arr, Arr^elem(0)).

maximum(image(Arr, _), Max) :-
    array.size(Arr) \= 0,
    Max = array.foldl(func(X,Y) = (if X @> Y then X else Y), Arr, Arr^elem(0)).
