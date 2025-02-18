:- module filter.

:- interface.

:- import_module shape, image, float, maybe, math, int, array2d.

:- type border_interpolation(T) ---> border_replicate ; border_reflect ; border_circular ; border_wrap ; border_constant(T).
% :- pred convolve(Image::in, Kernel::in, border_interpolation(float)::in, image(float)::out) is det.
% :- pred gaussian_blur(image(int)::in, int::in, maybe(float), image(int)::out) is det.
:- func gaussian(float, float) = float.
:- func gaussian_kernel(int, float) = image(float).


:- implementation.

gaussian(X, Sigma) = exp(-pow(X,2) / (2.0 * pow(Sigma, 2))) / (sqrt(2.0 * pi * pow(Sigma, 2))).

gaussian_kernel(Size, Sigma) = KernelImg :-
    Radius = Size // 2,
    Kernel = image.generate(size(Size, Size), 
        (func(point2d(Col, Row)) = gaussian(float(Row - Radius), Sigma) * gaussian(float(Col - Radius), Sigma))
    ),
    % Sum = array2d.foldl((func(X, Acc) = X + Acc), Kernel, 0.0),
    % NormalizedKernel = array2d.map((func(X) = X / Sum), Kernel).
    % KernelImg = image.from_array2d(NormalizedKernel).
    KernelImg = Kernel.

% gaussian_blur(SourceImg, BlurRadius, Sigma, BlurredImg) :-
    % BlurredImg = SourceImg.
