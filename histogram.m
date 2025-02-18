/*
    2D Image type based on mutable arrays. 
*/
:- module histogram.

:- interface.
:- import_module image, generic.

% :- typeclass arithmetic where [
    
% ].

% :- func normalize(image(float), float, float) = image(float).

:- func normalize(image(T), T, T) = image(T) <= (convert(T, float), convert(float, T)).

% :- func window_level(image(float), float, float, float, float) = image(float).

:- func window_level(image(T), T, T, T, T) = image(T) <= (convert(T, float), convert(float, T)).
:- implementation.
:- import_module float.

% normalize(Img, NewMin, NewMax) = NormalizedImg :-
%     (if 
%         image.minimum(Img, Min),
%         image.maximum(Img, Max)
%     then
%         NormalizedImg = image.map((func(I) = (I-Min)*(NewMax - NewMin)/(Max-Min) + NewMin), Img)
%     else
%         NormalizedImg = Img).

normalize(Img, NewMin, NewMax) = NormalizedImg  :-
    (if 
        image.minimum(Img, Min),
        image.maximum(Img, Max)
    then
        MinF = convert(Min), MaxF = convert(Max),
        NewMinF = convert(NewMin), NewMaxF = convert(NewMax),
        NormalizedImg = image.map(
            (func(I) = convert((convert(I)-MinF)*(NewMaxF - NewMinF)/(MaxF-MinF) + NewMinF)), 
            Img)
    else
        NormalizedImg = Img).

% window_level(Img, WindowCenter, WindowWidth, NewMin, NewMax) = NewImg :-
%     (NewImg = image.map(F, Img),
%     F = (func(I) = 
%         (   if I =< (WindowCenter - WindowWidth / 2.0)
%             then NewMin
%             else if I =< (WindowCenter + WindowWidth / 2.0)
%             then 
%                 NewMin + (NewMax-NewMin) * (I - (WindowCenter - WindowWidth / 2.0)) / WindowWidth
%             else NewMax
%         ))).


window_level(Img, WindowCenter, WindowWidth, NewMin, NewMax) = NewImg :-
    (NewImg = image.map(F, Img),
    WindowCenterF = convert(WindowCenter), WindowWidthF = convert(WindowWidth),
    NewMinF = convert(NewMin), NewMaxF = convert(NewMax),
    F = (func(I) = 
        (   if convert(I) =< (WindowCenterF - WindowWidthF / 2.0)
            then NewMin
            else if convert(I) =< (WindowCenterF + WindowWidthF / 2.0)
            then
                convert(
                    NewMinF + (NewMaxF - NewMinF) * (convert(I) - (WindowCenterF - WindowWidthF / 2.0)) / WindowWidthF
                )
            else NewMax
        ))).