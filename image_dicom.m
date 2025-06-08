:- module image_dicom.

:- interface.

:- import_module dicom, image, maybe, list, bool, histogram.

:- type dicom_object == list(dicom_element).

:- type dynamic_image ---> 
    image_u8(image(uint8))
    ; image_i8(image(int8))
    ; image_i16(image(int16))
    ; image_u16(image(uint16))
    ; image_f(image(float)).   
% :- func decode_dicom_image(dicom_object) = maybe_error(image, string).

:- func normalize_dynamic_image(dynamic_image) = dynamic_image.

:- pred extract_metadata(
    dicom_object::in, maybe(uint16)::out, maybe(uint16)::out,
    maybe(uint16)::out,
    maybe(uint16)::out,
    maybe(uint16)::out,
    maybe(string)::out,
    maybe(uint16)::out) is semidet.
    
:- func decode_dicom_image(dicom_object) = maybe_error(dynamic_image, string).


:- pred int8(int8, list(uint8), list(uint8)).
:- mode int8(out, in, out) is semidet.

:- pred int16_le(int16, list(uint8), list(uint8)).
:- mode int16_le(out, in, out) is semidet.

% :- pred uint32_le(uint32, list(uint8), list(uint8)).
% :- mode uint32_le(out, in, out) is semidet.
:- implementation.

:- import_module dicom_tags, array, string, uint16, shape, int16, int8.


normalize_dynamic_image(image_u8(I)) = image_u8(normalize_to_full_range(I)).
normalize_dynamic_image(image_u16(I)) = image_u16(normalize_to_full_range(I)).
normalize_dynamic_image(image_i8(I)) = image_i8(normalize_to_full_range(I)).
normalize_dynamic_image(image_i16(I)) = image_i16(normalize_to_full_range(I)).
normalize_dynamic_image(image_f(I)) = image_f(I).

decode_dicom_image(DicomObj) = DynamicImg :- (
    if 
        extract_metadata(
            DicomObj, yes(Rows), yes(Columns), 
            yes(BitsAllocated), yes(BitsStored), yes(HighBit), 
            yes(PhotometricInterpretation), yes(PixelRepresentation)
        )
    then 
        Find = 
            (func(Tag) = Elt :- Elt = (
                if     list.find_first_match((pred(E::in) is semidet :- E^element_tag = Tag), DicomObj, SearchRes)
                then yes(SearchRes^element_content)
                else no)
            ),
        (   if Find(pixel_data) = yes(PixelData) 
            then
                Meta = {BitsAllocated, string.strip(PhotometricInterpretation), PixelRepresentation},
                (if 
                    Meta = {8u16, "MONOCHROME2", 0u16}
                then
                    DynamicImg = ok(image_u8(
                        image(PixelData, 
                        size(to_int(Columns), to_int(Rows)))
                    ))
                   
                else if
                    Meta = {16u16,"MONOCHROME2",0u16},
                    read_all(uint16_le, Uint16List, array.to_list(PixelData), _)  
                then    
                     DynamicImg=ok(image_u16(
                        image(array.from_list(Uint16List), 
                        size(to_int(Columns), to_int(Rows)))
                    ))
                else if 
                    Meta = {8u16,"MONOCHROME2",1u16},
                    read_all(int8, Int8List, array.to_list(PixelData), _)
                then
                     DynamicImg=ok(image_i8(
                        image(array.from_list(Int8List), 
                        size(to_int(Columns), to_int(Rows)))
                    ))
                else if
                    Meta = {16u16,"MONOCHROME2",1u16},
                    read_all(int16_le, Int16List, array.to_list(PixelData), _)
                then
                        DynamicImg=ok(image_i16(
                        image(array.from_list(Int16List), 
                        size(to_int(Columns), to_int(Rows)))
                    ))
                else
                    {_,Interp,_} = Meta,
                    DynamicImg = error("Unrecognized type, only uint8 and uint16 are supported."
                     ++ "BitsAlloc=" ++ string(BitsAllocated) ++ ", Photometric Interp=" ++ string(Interp)
                     ++ ", PixelRepr=" ++ string(PixelRepresentation) 
                    
                    ) 
                        % Meta = R,
                    % DynamicImg = ok(image_u8(
                    % image(PixelData, 
                    % size(to_int(Columns), to_int(Rows)))
                    % ))
                )
            else DynamicImg=error("No PixelDataFound")
            )
    else DynamicImg=error("Error reading metadata")
).

:- pred find_dcm_element(tag::in, dicom_object::in, dicom_element::out) is semidet.
find_dcm_element(Tag, DicomObj, SearchRes) :- 
    list.find_first_match((pred(E::in) is semidet :- E^element_tag = Tag), DicomObj, SearchRes).

extract_metadata(DicomObj, Rows, Columns, BitsAllocated, BitsStored, HighBit, PhotometricInterpretation, PixelRepresentation) :-
    try_parse_maybe(uint16_le, Find(rows), Rows),
    try_parse_maybe(uint16_le, Find(columns), Columns),
    try_parse_maybe(uint16_le, Find(bits_allocated), BitsAllocated),
    try_parse_maybe(uint16_le,  Find(bits_stored), BitsStored),
    try_parse_maybe(uint16_le, Find(high_bit), HighBit),

    try_parse_maybe(ParseString, Find(photometric_interpretation), PhotometricInterpretation),
    try_parse_maybe(uint16_le,  Find(pixel_representation), PixelRepresentation),
    Find = 
        (func(Tag) = Elt :- Elt = (
            if     list.find_first_match((pred(E::in) is semidet :- E^element_tag = Tag), DicomObj, SearchRes)
            then yes(array.to_list(SearchRes^element_content))
            else no)
        )
    ,
    ParseString = (pred(Str::out, InBytes::in, OutBytes::out) is semidet :-
        OutBytes = [],
        Str = string.from_char_list(map(uint8_to_char, InBytes))  
    ).


:- pred try_parse_maybe(pred(T, list(uint8), list(uint8)), maybe(list(uint8)), maybe(T)).
:- mode try_parse_maybe(in(pred(out, in, out) is semidet), in, out).

try_parse_maybe(_, no, no).
try_parse_maybe(P, yes(InBytes), Res) :- (if P(T, InBytes, _) then Res=yes(T) else Res=no).

% read_chars(list())
:- func unnest_maybe(maybe(maybe(T))) = maybe(T).
unnest_maybe(no) = no.
unnest_maybe(yes(no)) = no.
unnest_maybe(yes(yes(T))) = yes(T).



int8(Int8) --> [Byte], {Int8 = int8.cast_from_uint8(Byte)}.
int16_le(Int16) --> [Byte1, Byte2], {Int16 = int16.from_bytes_le(Byte1, Byte2)}.

% uint32_le(Uint32) --> [Byte1, Byte2, Byte3, Byte4], {Uint32 = uint32.from_bytes_le(Byte1, Byte2, Byte3, Byte4)}.
