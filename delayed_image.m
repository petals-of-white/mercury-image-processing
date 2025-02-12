:- module delayed_image.

:- interface.

:- import_module shape.

:- type delayed_image(T) ---> delayed_image(
    delayed_size::size,
    delayed_func::(func(coord2D)=T is semidet)).

:- func map((func(A) = B), delayed_image(A)) = delayed_image(B).

:- pred lookup_pixel(delayed_image(T)::in, int::in, int::in, T::out) is semidet.