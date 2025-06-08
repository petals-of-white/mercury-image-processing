:- module filter.

%######################################################################################
:- interface.

:- import_module image, array, maybe.

% border interpolation handling
:- type border_interpolation(T) 
    ---> border_replicate
        ; border_reflect
        ; border_wrap
        ; border_constant(T).

:- type interpol_result(T) ---> interpolated_index(int); constant_value(T).

% border_interpolate(InterpolMethod, Length, Index).
:- func border_interpolate(border_interpolation(T), int, int) = interpol_result(T).

% -- Gaussian function. gaussian(X, Sigma).
:- func gaussian(float, float) = float.

% Gaussian kernels
% 2D gaussian kernel. gaussian_kernel(Radius, Sigma) = Kernel2D.
:- func gaussian_kernel(int, float) = image(float).

% 1D gaussian kernel. gaussian_kernel1D(Radius, Sigma) = Kernel1D.
:- func gaussian_kernel1D(int, maybe(float)) = array(float).

% Apply gaussian blur using separable kernel. 
% gaussian_blur(Source, Radius, MaybeSigma, InterpolMethod, BlurredOutput).
:- pred gaussian_blur(image(float)::in, int::in, maybe(float)::in, border_interpolation(float)::in, image(float)::out) is det.

% -- Convolution
% convolveX(Image, Kernel, InterpolMethod) = Result.
:- func convolveX(image(float), array(float), border_interpolation(float)) = image(float).

% convolveY(Image, Kernel, InterpolMethod) = Result.
:- func convolveY(image(float), array(float), border_interpolation(float)) = image(float).

%##########################################################################################

:- implementation.

:- import_module shape, float, math, int, array2d.

gaussian_kernel1D(Radius, MaybeSigma) = Kernel :- (
    Size = Radius * 2 + 1,
    Sigma = (if MaybeSigma = yes(S) then S else (0.5 + float(Radius)) / 3.0),
    Kernel = array.generate(
        Size, 
        (func(X)= G :- G = gaussian(float(abs(X - Radius)), Sigma))
    )
).

gaussian(X, Sigma) = exp(-pow(X, 2) / (2.0 * pow(Sigma, 2))) / (sqrt(2.0 * pi * pow(Sigma, 2))).

gaussian_kernel(Radius, Sigma) = Kernel :-
    % Radius = Size // 2,
    Size = Radius * 2 + 1,
    Kernel = image.generate(
        size(Size, Size), 
        (func(point2d(Col, Row)) = 
            gaussian(float(Row - Radius), Sigma) * gaussian(float(Col - Radius), Sigma))
    ).

gaussian_blur(InputImg, Radius, MaybeSigma, BorderInterpol, OutImg) :-
    GaussVector = gaussian_kernel1D(Radius, MaybeSigma),
    ConvolvedVert = convolveY(InputImg, GaussVector, BorderInterpol),
    ConvolvedHorz = convolveX(ConvolvedVert, GaussVector, BorderInterpol),
    OutImg = ConvolvedHorz.

border_interpolate(Interpolation, Length, Index) = R :- (
    if (Index < Length, Index >= 0)
    then R = interpolated_index(Index)
    else
        (
            Interpolation = border_replicate,
            (   if Index < 0 
                then R = interpolated_index(0)
                else R = interpolated_index(Length - 1)
            )
            ;
            Interpolation = border_reflect,
            R = interpolated_index(reflect_border(Length,Index))
            ;
            Interpolation = border_wrap,
            R = interpolated_index(Index mod Length)
            ;
            Interpolation = border_constant(C),
            R = constant_value(C)
        )
).


convolveX(SrcImg, Kernel, InterpolMethod) = OutImg :- (
    KernelCenter = array.size(Kernel) mod 2,
    Length = SrcImg^image_size^width,
    OutImg = image.generate(
        SrcImg^image_size,
        CalculatePixel
    ),
    CalculatePixel =         
        (func(point2d(X,Y)) = NewPix :-
            InitIndex = X - KernelCenter,
            array.foldl2(
                (pred(KernelValue::in, CurrentSum::in, NewSum::out, CurrentIndex::in, NewIndex::out) is det :-
                    InterpolResult = border_interpolate(InterpolMethod, Length, CurrentIndex),
                    (
                        InterpolResult = interpolated_index(XPos), 
                        CurrentPix = image.det_get_pixel(SrcImg, point2d(XPos, Y))
                        ;
                        InterpolResult = constant_value(CurrentPix)
                    ),
                    NewSum = CurrentSum + KernelValue * CurrentPix,
                    NewIndex = CurrentIndex + 1
                ),
                Kernel, 0.0, NewPix, InitIndex, _
            )
        )
).

convolveY(SrcImg, Kernel, InterpolMethod) = OutImg :- (
    KernelCenter = array.size(Kernel) mod 2,
    Length = SrcImg^image_size^height,
    OutImg = image.generate(
        SrcImg^image_size,
        CalculatePixel
    ),
    CalculatePixel =         
        (func(point2d(X,Y)) = NewPix :-
            InitIndex = Y - KernelCenter,
            array.foldl2(
                (pred(KernelValue::in, CurrentSum::in, NewSum::out, CurrentIndex::in, NewIndex::out) is det :-
                    InterpolResult = border_interpolate(InterpolMethod, Length, CurrentIndex),
                    (
                        InterpolResult = interpolated_index(YPos), 
                        CurrentPix = image.det_get_pixel(SrcImg, point2d(X, YPos))
                        ;
                        InterpolResult = constant_value(CurrentPix)
                    ),
                    NewSum = CurrentSum + KernelValue * CurrentPix,
                    NewIndex = CurrentIndex + 1
                ),
                Kernel, 0.0, NewPix, InitIndex, _
            )
        )
).

:- func reflect_border(int, int) = int.
reflect_border(Length, Ix) = (
    if (Ix < 0)
    then reflect_border(Length, -Ix - 1)
    else if Ix >= Length
    then reflect_border(Length, (Length - 1) - (Ix - Length))
    else Ix
).