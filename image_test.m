:- module image_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list, image, string, histogram, float, image_io, int.

main(!IO) :-
    Lists = [
        [0,1,2,3],
        [4,5,6,7],
        [8,9,10,11],
        [12,13,14,15]
    ],
    (if 
        image.from_lists(Lists,Img),
        image.minimum(Img, Min),
        image.maximum(Img, Max),
        FloatImg = image.map(float, Img),
        NormalizedImg = histogram.normalize(FloatImg, 0.0, 1.0),

        WindowLeveled = histogram.window_level(FloatImg, 8.0, 8.0, 100.0, 200.0)
    then
        io.write_string("Original image!\n",!IO),
        io.write_line(Img, !IO),
        io.format("Minimum: %d, Maximum: %d", [i(Min), i(Max)], !IO),
        io.write_string("Image float: \n", !IO),
        io.write_line(FloatImg, !IO),
        io.write_string("Normalized image: \n", !IO),
        io.write_line(NormalizedImg, !IO),
        io.write_string("Window level applied: \n",!IO),
        io.write_line(WindowLeveled, !IO),
        save_bmp("original.bmp", NormalizedImg, !IO)
    else
        io.write_string("Sad noises.\n", !IO)
    ).