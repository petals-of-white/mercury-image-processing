:- module test_filter.

:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module list, filter, string, pretty_printer, maybe.

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    (if 
        Args = [RadiusStr, SigmaStr],
        to_int(RadiusStr, Size),
        to_float(SigmaStr, Sigma)
    then
        Kernel = gaussian_kernel(Size, Sigma),

        % creating gaussian kernel 1d with automatically calculated sigma
        Kernel1D = gaussian_kernel1D(Size, no),
        Nice = format(Kernel),
        io.write_string("Kernel 2D: ", !IO),
        io.nl(!IO),
        write_doc(Nice, !IO),
        io.nl(!IO),
        io.write_string("Kernel 1D", !IO),
        write_doc(format(Kernel1D), !IO)
    else 
        io.write_string("Usage: test_filter <radius> <sigma>", !IO),
        io.nl(!IO)
    ).