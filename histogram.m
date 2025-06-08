:- module histogram.

:- interface.
:- import_module image, generic.

% :- func normalize(image(float), float, float) = image(float).

:- func normalize(image(T), T, T) = image(T) <= (convert(T, float), convert(float, T)).
:- func normalize_to_full_range(image(T)) = image(T) <= (convert(T, float), convert(float, T), bounded(T)).
% :- func window_level(image(float), float, float, float, float) = image(float).

:- func window_level(image(T), T, T, T, T) = image(T) <= (convert(T, float), convert(float, T)).
:- implementation.
:- import_module float.


window_level(Img, WindowCenter, WindowWidth, NewMin, NewMax) = NewImg :-(
    NewImg = image.map(F, Img),
    WindowCenterF = ToF(WindowCenter), WindowWidthF = ToF(WindowWidth),
    NewMinF = ToF(NewMin), NewMaxF = ToF(NewMax),
    F = (func(I) = 
        (   if ToF(I) =< (WindowCenterF - WindowWidthF / 2.0)
            then NewMin
            else if ToF(I) =< (WindowCenterF + WindowWidthF / 2.0)
            then
                FromF(
                    NewMinF + (NewMaxF - NewMinF) * (ToF(I) - (WindowCenterF - WindowWidthF / 2.0)) / WindowWidthF
                )
            else NewMax
        )),
        ToF = convert,
        FromF = convert).

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

normalize_to_full_range(Img) = normalize(Img, min_bound, max_bound).


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
% normalize(Img, NewMin, NewMax) = NormalizedImg :-
%     (if 
%         image.minimum(Img, Min),
%         image.maximum(Img, Max)
%     then
%         NormalizedImg = image.map((func(I) = (I-Min)*(NewMax - NewMin)/(Max-Min) + NewMin), Img)
%     else
%         NormalizedImg = Img).
