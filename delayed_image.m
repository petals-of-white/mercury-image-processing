:- module delayed_image.

:- interface.

:- import_module shape, image.
:- type delayed_image(T) ---> delayed_image(
    delayed_size::size,
    delayed_func::(func(point2d)=T)).

:- pred get_pixel(delayed_image(T)::in, point2d::in, T::out) is det.

% :- pred set_pixel(point2d::in, T::in, delayed_image(T)::in, delayed_image(T)::out) is semidet.

:- func from_array_image(image.image(T)) = delayed_image(T).

:- func to_array_image(delayed_image(T)) = image(T).

% :- pred minimum(delayed_image(T)::in, T::out) is semidet.

% :- pred maximum(delayed_image(T)::in, T::out) is semidet.

:- func map((func(A) = B), delayed_image(A)) = delayed_image(B).

:- implementation.

get_pixel(DelayedImg, Point, Pixel) :- Pixel = (DelayedImg ^ delayed_func)(Point).

% set_pixel(Point, Pixel, delayed_image(Size, F), Img2) :-
%     Img2 = delayed_image(Size, (func(P) = (if P = Point then Pixel else F(P)))).

map(F, delayed_image(Size, G)) = delayed_image(Size, (func(P) = F(G(P)))).

from_array_image(Img) = delayed_image(
    (Img ^ image.image_size),
    (func(Point) =  Pixel :- image.det_get_pixel(Img, Point) = Pixel)
    ).


to_array_image(DelayedImg) = image.generate(DelayedImg ^ delayed_size, DelayedImg ^ delayed_func).