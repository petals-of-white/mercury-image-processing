:- module dicom_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module string, list, maybe, time, gc, int, float.
:- import_module filter, image_dicom, dicom, generic, image, image_io, pixel.


:- pred save_dyn_img_bmp(dynamic_image::in, string::in, io::di, io::uo) is det.
save_dyn_img_bmp(SourceImg, Path, !IO) :-
Img = normalize_dynamic_image(SourceImg),
(
    Img = image_u8(I),
    save_bmp(Path, I, !IO)
;
    Img = image_u16(I),
    save_bmp(Path, I, !IO)
;
    Img = image_i8(I),
    save_bmp(Path, I, !IO)
;
    Img = image_i16(I),
    save_bmp(Path, I, !IO)
;
    Img = image_f(I),
    save_bmp(Path, I, !IO)  
).
:- func show_dyn_image(dynamic_image) = string.
show_dyn_image(image_u8(_)) = "image_u8".
show_dyn_image(image_u16(_)) = "image_u16".
show_dyn_image(image_i8(_)) = "image_i8".
show_dyn_image(image_i16(_)) = "image_i16".
show_dyn_image(image_f(_)) = "image_f".

:- func dynamic_img_to_float(dynamic_image) = image(float).
dynamic_img_to_float(image_u8(I)) = image.map(convert, I).
dynamic_img_to_float(image_u16(I)) = image.map(convert, I).
dynamic_img_to_float(image_i8(I)) = image.map(convert, I).
dynamic_img_to_float(image_i16(I)) = image.map(convert, I).
dynamic_img_to_float(image_f(I)) = I.

:- pred read_dicom_from_file(string::in, io.result(maybe_error(dicom_object, string))::out, io::di, io::uo).
read_dicom_from_file(FilePath, Result ,!IO) :-
dicom.read_file_byte_list(FilePath, Res, !IO),
(
    Res = ok(Bytes),
    (if read_dicom_object(Obj, Bytes, _) then 
        Result = ok(ok(Obj))
    else
        Result = ok(error("Error while parsing DICOM"))
    )
;
    Res = eof, Result = eof
;
    Res = error(Err), Result = error(Err)
).

main(!IO) :- 
io.command_line_arguments(Args, !IO),
(if Args = [DicomPath, StrKernelRadius | Rest] then
    io.write_string("Starting to parse a DICOM file...", !IO),
    read_dicom_from_file(DicomPath, ResultDicom, !IO),
    (
        ResultDicom = ok(ok(Dicom)),
        MaybeImg = decode_dicom_image(Dicom),
        (
            MaybeImg = ok(DynamicImg),
            io.write_string("Successfully read an image. Converting to float... \n", !IO),
            save_dyn_img_bmp(DynamicImg, "original.bmp", !IO),
            KernelRadius = string.det_to_int(StrKernelRadius),
            Sigma = (if Rest = [SigmaStr | _] then yes(string.det_to_float(SigmaStr)) else no),
            FloatImg = dynamic_img_to_float(DynamicImg),
            io.format("Radius=%d, Sigma=%s", [i(KernelRadius), s(string(Sigma))], !IO),
            io.write_string("Applying gaussian blur..\n", !IO),
            gc.garbage_collect(!IO),
            time.clock(Start, !IO),
            % time.time(Start, !IO),
            gaussian_blur(FloatImg, KernelRadius, Sigma, border_replicate, BlurredF),
            time.clock(Finish, !IO),
            DiffTime = (float(Finish) - float(Start)) / float(time.clocks_per_sec),
            % time.time(Finish, !IO),
            % time.difftime(Finish, Start)=SecondsPassed,
            io.format("%f seconds passed", [f(DiffTime)], !IO),
            io.write_string("applied gaussian blur\n", !IO),

            save_dyn_img_bmp(image_i16(image.map(convert, BlurredF)), "Blurred.bmp", !IO)

            % io.write_line(FloatImg, !IO)
        ;
            MaybeImg = error(Err),
            io.write_string(Err, !IO),
            io.nl(!IO)
        )
    ;
        ResultDicom=ok(error(Err)),
        io.write_line(Err, !IO)
    ;
        ResultDicom = eof, io.write_line("EOF", !IO)
    ;
        ResultDicom = error(Err), io.write_line(Err, !IO)
    )
else
    io.write_string("Usage: dicom_test <dicompath> <kernel_radius> <sigma>", !IO)
).