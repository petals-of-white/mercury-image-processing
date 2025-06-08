:- module segmentation.

% ####################################################################
:- interface.
:- import_module image, quadtree, maybe.
:- import_module list.

:- type region_statistics(A) ---> region_statistics(
    region_min ::   A,
    region_max ::    A,
    region_average :: A,
    region_std :: A,
    region_sum_intensity :: int,
    region_num_pixels :: int
).

:- type region(Info) ---> region(
    region_id::int,
    region_info::Info,
    region_extent :: rect
).

:- type group_region(Info) ---> group_region(
    group_id :: int,
    group_info :: Info,
    children_regions :: list(region(Info))
).

:- type merge_error ---> not_homogeneous; not_connected.

:- pred compute_stats(image(A)::in, region_statistics(A)::out) is semidet.

:- func singleton_group(int, region(A)) = group_region(A).
% :- mode singleton_group(in, in, out) is det.

:- pred is_touching_group(region(A)::in, group_region(A)::in) is semidet.

:- pred extent_neighbours(rect::in, rect::in) is det.

:- func group_to_image(group_region(A)) = image(A).
:- mode group_to_image(in) = image_uo is det.

:- pred region_split(pred(image(P), V), image(P), quadtree({V, int})).
:- mode region_split(pred(image_ui, out) is semidet, image_ui, out) is det.

:- func merge_regions(
    func(region(Info), group_region(Info)) = maybe_error(group_region(Info), merge_error),
    quadtree({Info, int}),
    rect
) = list(group_region(Info)).

:- mode merge_regions((func(in, in)=out is det), in, in) = out is det.

% ####################################################################
:- implementation.

:- import_module int.

region_split(Homogeneous, SourceImg, QuadTree) :-
    SourceImg^image_size = size(Width, Height),
    {QuadTree, _NextId} = make_tree(Homogeneous, SourceImg, rect(0,0, Width, Height), 0). 

:- pred make_tree(pred(image(P), V), image(P), rect, int, quadtree(V), int).
:- mode make_tree(pred(in, out) is semidet, image_ui, in, in, out, out) is det.
make_tree(Homogeneous, SrcImg, rect(Rx, Ry, RWidth, RHeight), QuadTree, CurrentId) :- 
    SrcImg ^ image_size = size(ImgWidth, ImgHeight),
    (if Rx < 0; Ry < 0; Ry + RHeight > ImgHeight ; Rx + RWidth > ImgWidth then
        error("Wow, something bad happened!")
    else if W = 0; H = 0 then 
        QuadTree = nil, 
    ).

merge_regions(Merger, QuadTree, Rect) = MergeResult :- (
    foldl2(AddToGroup, quadtree.dfs(QuadTree, Rect), [], MergeResult, 0, _),
    AddToGroup =    
        (pred({{RegInfo, RegId}, Extent}::in, OldGroups::in, NewGroups::out,
              OldGroupId::in, NewGroupId::out) is det :-
            
            Region = region(RegId, RegInfo, Extent),
            (if list.find_first_map(
                    (pred(Group::in, UpdGroup::out) is semidet
                        :- Merger(Region, Group) = ok(UpdGroup)), 
                    OldGroups, PotentialGroup
                ) then
                NoDuplicates = list.filter(
                    (pred(G::in) is semidet :- G^group_id \= PotentialGroup^group_id),
                    OldGroups),
                NewGroups = [PotentialGroup | NoDuplicates],
                NewGroupId = OldGroupId
            else
                NewGroups = [singleton_group(OldGroupId, Region) | OldGroups],
                NewGroupId = OldGroupId + 1
            )
        )
).
