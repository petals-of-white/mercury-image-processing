/*
    2D Image type based on mutable arrays. 
*/
:- module image.

:- interface.

:- import_module shape, list, array2d, array.

:- type image(T)    --->  image(pixel_array::array(T), image_size::size).

:- func init(size, T) = image(T).

:- func generate(size, (func(point2d) = T)) = image(T).

:- func map((func(A) = B), image(A)) = image(B).

:- pred get_pixel(image(T)::in, point2d::in, T::out) is semidet.

:- func det_get_pixel(image(T), point2d) = T.

:- pred set_pixel(point2d::in, T::in, image(T)::di, image(T)::out) is semidet.

:- pred minimum(image(T)::in, T::out) is semidet.
:- pred maximum(image(T)::in, T::out) is semidet.


:- pred from_lists(list(list(T))::in, image(T)::out) is semidet.
:- func to_array(image(T)) = array(T).
:- pred to_array2d(image(T)::di, array2d(T)::array2d_uo) is det.


:- implementation.

:- import_module int.

init(Size, InitVal) = image(array.init(Size^width * Size^height, InitVal), Size).

generate(Size@size(Width, Height), F) = 
    image(
        array.generate(
            Width * Height,
            (func(I) = Value :- (Y = I div Height, X = I mod Height, Value = F(point2d(X, Y))))),
        Size).
    
map(F, image(Arr, Size)) = OutputImg :-
    NewArr = array.map(F, Arr),
    OutputImg = image(NewArr, Size).

get_pixel(image(Arr, Size), Point, Pixel) :-
    LinearCoord = (Point^y * Size^height) + (Point^x),
    array.semidet_lookup(Arr, LinearCoord, Pixel).

det_get_pixel(image(Arr, Size), Point) = Pixel :-
    (LinearCoord = (Point^y * Size^height) + (Point^x),
    Pixel = array.lookup(Arr, LinearCoord)).

set_pixel(Point, Pixel, InputImg, OutputImg) :-
    InputImg = image(InputArr, Size),
    LinearCoord = (Point^y * Size^height) + (Point^x),
    array.semidet_set(LinearCoord, Pixel, InputArr, OutputArr),
    OutputImg = image(OutputArr, Size).    

to_array2d(image(Arr, Size), Array2D) :-
    Array2D = array2d.from_array(Size^height, Size^width, Arr).

to_array(image(Arr, _)) = Arr.
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
