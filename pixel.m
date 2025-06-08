:- module pixel.

:- interface.

:- import_module uint8, uint16, int16, generic, std_util, float.

:- type rgb(T) ---> rgb(red::T, green::T, blue::T).

% :- instance convertible_pixels(A, B) .
:- typeclass convertible_pixels(A, B) where[
    func convert_pixel(A) = B
].

:- instance convertible_pixels(uint8, uint8).
:- instance convertible_pixels(int8, uint8).
:- instance convertible_pixels(uint16, uint8).
:- instance convertible_pixels(int16, uint8).
:- instance convertible_pixels(int, uint8).
:- instance convertible_pixels(float, uint8).
:- instance convertible_pixels(float, int8).

% :- instance convertible_pixels(float, uint8).

:- instance convertible_pixels(uint8, rgb(T)) <= convertible_pixels(uint8, T).
:- instance convertible_pixels(uint16, rgb(T)) <= convertible_pixels(uint16, T).
:- instance convertible_pixels(int8, rgb(T)) <= convertible_pixels(int8, T).
:- instance convertible_pixels(int16, rgb(T)) <= convertible_pixels(int16, T).
:- instance convertible_pixels(int, rgb(T)) <= convertible_pixels(int, T).
:- instance convertible_pixels(float, rgb(T)) <= convertible_pixels(float, T).

:- implementation.

:- instance convertible_pixels(uint8, uint8) where [
    func(convert_pixel/1) is id
].

:- instance convertible_pixels(uint16, uint8) where [
    func(convert_pixel/1) is proportionally_convert
].

:- instance convertible_pixels(int8, uint8) where [
    func(convert_pixel/1) is proportionally_convert
].
:- instance convertible_pixels(int16, uint8) where [
    func(convert_pixel/1) is proportionally_convert
].

:- instance convertible_pixels(int, uint8) where [
    func(convert_pixel/1) is proportionally_convert
].

:- instance convertible_pixels(float, uint8) where [
    convert_pixel(Pixel) = convert(convert(min_bound:uint8) + Pixel * (convert(max_bound:uint8) - convert(min_bound:uint8)))
].

:- instance convertible_pixels(float, int8) where [
    convert_pixel(Pixel) = convert(convert(min_bound:int8) + Pixel * (convert(max_bound:uint8) - convert(min_bound:int8)))
].
:- instance convertible_pixels(uint8, rgb(T)) <= convertible_pixels(uint8, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].

:- instance convertible_pixels(uint16, rgb(T)) <= convertible_pixels(uint16, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].

:- instance convertible_pixels(int8, rgb(T)) <= convertible_pixels(int8, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].

:- instance convertible_pixels(int16, rgb(T)) <= convertible_pixels(int16, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].

:- instance convertible_pixels(int, rgb(T)) <= convertible_pixels(int, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].

:- instance convertible_pixels(float, rgb(T)) <= convertible_pixels(float, T) where [
    convert_pixel(Pixel) = Rgb :- (Rgb = rgb(Converted, Converted, Converted), Converted = convert_pixel(Pixel))
].