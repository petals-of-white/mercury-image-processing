/*
    2D Image type based on mutable arrays. 
*/
:- module histogram.

:- interface.
:- import_module image.

% :- typeclass arithmetic where [
    
% ].

:- func normalize(image(float), float, float) = image(float).

:- func window_level(image(float), float, float, float, float) = image(float).

:- implementation.
:- import_module float.

normalize(Img, NewMin, NewMax) = NormalizedImg :-
    (if 
        image.minimum(Img, Min),
        image.maximum(Img, Max)
    then
        NormalizedImg = image.map((func(I) = (I-Min)*(NewMax - NewMin)/(Max-Min) + NewMin), Img)
    else
        NormalizedImg = Img).

window_level(Img, WindowCenter, WindowWidth, NewMin, NewMax) = NewImg :-
    (NewImg = image.map(F, Img),
    F = (func(I) = 
        (   if I =< (WindowCenter - WindowWidth / 2.0)
            then NewMin
            else if I =< (WindowCenter + WindowWidth / 2.0)
            then 
                NewMin + (NewMax-NewMin) * (I - (WindowCenter - WindowWidth / 2.0)) / WindowWidth
            else NewMax
        ))).