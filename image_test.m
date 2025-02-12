:- module image_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module list, image, string, histogram, float.

main(!IO) :-
    Lists = [
        [5,2,5],
        [7,1,6],
        [3,0,9]
    ],
    (if 
        image.from_lists(Lists,Img),
        image.minimum(Img, Min),
        image.maximum(Img, Max),
        FloatImg = image.map(float, Img),
        NormalizedImg = histogram.normalize(FloatImg, 0.0, 20.0),
        WindowLeveled = histogram.window_level(FloatImg, 4.5, 9.0, 100.0, 200.0)
    then
        io.write_string("Original image!\n",!IO),
        io.write_line(Img, !IO),
        io.format("Minimum: %d, Maximum: %d", [i(Min), i(Max)], !IO),
        io.write_string("Image float: \n", !IO),
        io.write_line(FloatImg, !IO),
        io.write_string("Normalized image: \n", !IO),
        io.write_line(NormalizedImg, !IO),
        io.write_string("Window level applied: \n",!IO),
        io.write_line(WindowLeveled, !IO)
    else
        io.write_string("Sad noises.\n", !IO)
    ).