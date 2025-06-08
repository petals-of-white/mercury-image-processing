:- module bad_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list, shape, array2d, image.

main(!IO) :-
    Lists = [
        [0,1,2,3],
        [4,5,6,7],
        [8,9,10,11],
        [12,13,14,15]
    ],
    (if 
        image.from_lists(Lists, Img)
    then
        det_set_pixel(point2d(2,2), 4, Img, NewImg),
        io.write_line(NewImg, !IO)
    else
        io.write_string("wawa", !IO)
    ).