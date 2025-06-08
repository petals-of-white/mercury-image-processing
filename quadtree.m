:- module quadtree.

% #########################################################
:- interface.

:- import_module image, shape.
:- import_module list.

:- type rect ---> rect(r_x::int, r_y::int, r_width::int, r_heigh::int).

:- type quad ---> nw; ne; se; sw.

:- type quadtree(A) ---> nil; leaf(A); node(nw::quadtree(A), ne::quadtree(A), se::quadtree(A), sw::quadtree(A)).

:- func map((func(A)=B), quadtree(A)) = quadtree(B).

:- func take_quad_of_rect(quad, rect) = rect.

:- func dfs(quadtree(A), rect) = list({A, rect}). 

:- func to_image((func(A, rect) = B), B, quadtree(A), size) = image(B).
:- mode to_image((func(in,in)=out is det), in, in, in) = image_uo is det.

:- pred write_rect_image(rect::in, Pix::in, image(Pix)::image_di, image(Pix)::image_uo) is det.

:- func points_in_rect(rect) = list(point2d).
% :- pred semidet_write_rect_image(rect::in, Pix::in, image(Pix)::di, image(Pix)::out) is semidet.



% #########################################################
:- implementation.
:- import_module float, ranges, solutions, int.

map(_, nil) = nil.
map(F, leaf(A)) = leaf(F(A)).
map(F, node(NW, NE, SE, SW)) = node(map(F,NW), map(F, NE), map(F, SE), map(F, SW)).

take_quad_of_rect(Q, rect(X, Y, Width, Height)) = NewRect :- (
    (
        Q = nw, NewRect = rect(X, Y, HalfW, HalfH)
    ;
        Q = ne, NewRect = rect(X + HalfW, Y, Width - HalfW, HalfH)
    ;
        Q = se, NewRect = rect(X + HalfW, Y+HalfH, Width - HalfW, Height - HalfH)
    ;
        Q = sw, NewRect = rect(X, Y + HalfH, HalfW, Height - HalfH)
    ),
    HalfW = ceiling_to_int(float(Width) / 2.0),
    HalfH = ceiling_to_int(float(Height) / 2.0)
).

dfs(nil, _) = [].
dfs(leaf(Value), Rect) = [{Value, Rect}].
dfs(node(NW, NE, SE, SW), Rect) = DfsList :- (
    DfsList = list.condense([dfs(NW, RectNW), dfs(NE, RectNE), dfs(SE, RectSE), dfs(SW, RectSW)]),
    RectNW = take_quad_of_rect(nw, Rect),
    RectNE = take_quad_of_rect(ne, Rect),
    RectSE = take_quad_of_rect(se, Rect),
    RectSW = take_quad_of_rect(sw, Rect)
).


to_image(F, Default, QuadTree, Size@size(Width, Height)) = ResImage :- (
    quadtree.foldl(
        (pred({Value, Rect}::in, SrcImg::image_di, OutImg::image_uo) is det :- 
            write_rect_image(Rect, F(Value, Rect), SrcImg, OutImg)),
        dfs(QuadTree,rect(0,0,Width,Height)),
        image.init(Size,Default),
        ResImage
    )
).

write_rect_image(Rect, Value, SrcImg, OutImg) :-
    quadtree.foldl(
        (pred(Point::in, InImg::image_di, NextImg::image_uo) is det :-
            image.det_set_pixel(Point, Value, InImg, NextImg)
        ),
        points_in_rect(Rect), SrcImg, OutImg).

points_in_rect(rect(Rx, Ry, Width, Height)) = solutions(
    (pred(point2d(X,Y)::out) is nondet :-
        ranges.nondet_member(X, range(Rx, Rx + Width - 1)),
        ranges.nondet_member(Y, range(Ry, Ry + Height - 1))
    )).

:- pred foldl(pred(T, A, A), list(T), A, A).
:- mode foldl((pred(in, image_di, image_uo) is det), in, image_di, image_uo) is det.
foldl(_, [], !Acc).
foldl(P, [X | Xs], Acc, Next) :-
    P(X, Acc, Next1),
    quadtree.foldl(P, Xs, Next1, Next).