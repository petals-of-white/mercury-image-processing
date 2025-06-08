:- module speed_test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module string, list, maybe, time, gc, int, float.
:- import_module filter, image_dicom, dicom, generic, image, pixel, shape.


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



:- pred measure_time(pred(A), float,  io, io).
:- mode measure_time(pred(out) is det, out, di, uo) is det.

measure_time(P, DiffTime, !IO) :-
    gc.garbage_collect(!IO),
    time.clock(Start, !IO),
    % time.time(Start, !IO),
    P(_Res),
    time.clock(Finish, !IO),
    % io.write_line(Res, !IO),
    DiffTime = (float(Finish) - float(Start)) / float(time.clocks_per_sec).

:- pred measure_for(pred(A), float, float, int, float, io, io).
:- mode measure_for(pred(out) is det, in, in, in, out, di, uo) is det.
measure_for(P, For, Ellapsed, Count, Average, !IO) :-
    (if Ellapsed > For then
        Average = Ellapsed / float(Count)
    else
        measure_time(P, Single, !IO),
        measure_for(P, For, Ellapsed+Single, Count+1, Average, !IO)
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
                
                KernelRadius = string.det_to_int(StrKernelRadius),
                Sigma = (if Rest = [SigmaStr | _] then yes(string.det_to_float(SigmaStr)) else no),
                FloatImg = dynamic_img_to_float(DynamicImg),
                io.format("Radius=%d, Sigma=%s", [i(KernelRadius), s(string(Sigma))], !IO),
                io.write_string("Applying gaussian blur..\n", !IO),
                ComputeBlur = (pred(Blurred::out) is det :- gaussian_blur(FloatImg, KernelRadius, Sigma, border_replicate, Blurred)),
                % measure_time(ComputeBlur, Avg, !IO),
                measure_for(ComputeBlur, 5.0, 0.0, 0, Avg, !IO),
                io.format("Avg time for gaussin blur with r=%d ---> %f", [i(KernelRadius),f(Avg)], !IO),
                ComputeBlur(BlurredF),
                dicom.read_file_byte_list(DicomPath, DicomBytesRes, !IO),
                (
                    DicomBytesRes = ok(DicomBytes),
                    ParseDicom = (pred(MaybeDicom::out) is det :- if dicom.read_dicom_object(Obj,DicomBytes, _) then MaybeDicom=yes(Obj) else MaybeDicom=no),
                    % (if dicom.read_dicom_object(Obj_, DicomBytes, _) then io.write_line(Obj_, !IO) else io.write_string("No parse",!IO)),
                    % measure_time(ParseDicom, AvgParse, !IO),
                    measure_for(ParseDicom, 5.0, 0.0, 0, AvgParse, !IO),
                    io.format("Avg time for dicom parsing ---> %f\n", [f(AvgParse)], !IO)
                ;
                    DicomBytesRes = eof,
                    io.write_string("Eof\n", !IO)
                ;
                    DicomBytesRes = error(Err),
                    io.write_string("IO Error: ", !IO),
                    io.write_line(Err, !IO)
                ),
                % gc.garbage_collect(!IO),
                % time.clock(Start, !IO),
                % % time.time(Start, !IO),
                % gaussian_blur(FloatImg, KernelRadius, Sigma, border_replicate, BlurredF),
                % time.clock(Finish, !IO),
                % DiffTime = (float(Finish) - float(Start)) / float(time.clocks_per_sec),
                % time.time(Finish, !IO),
                % time.difftime(Finish, Start)=SecondsPassed,
                % io.format("%f seconds passed", [f(DiffTime)], !IO),
              
                % io.write_string("applied gaussian blur\n", !IO),
                % io.write_line(BlurredF^image_size, !IO),
                io.write_line(image.det_get_pixel(BlurredF, point2d(2,2)), !IO)

                % io.write_line(FloatImg, !IO)
            ;
                MaybeImg = error(Err),
                io.write_string("Error while decoding img: " ++ Err ++ "\n", !IO),
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