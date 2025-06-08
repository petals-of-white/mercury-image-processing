:- module test.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module dicom, dicom_test.

main(!IO) :- io.write_line(undefined_value_length, !IO).