:- module image_io.

:- interface.
:- import_module string, io, image, generic, pixel.

:- type foreing_bitmap.

:- pragma foreign_type("C#", foreing_bitmap, "AnyBitmap").

:- pred save_bmp(string::in, image(T)::in, io::di, io::uo) is det <= convertible_pixels(T, rgb(uint8)).

:- func to_foreign_bitmap(image(T)) = foreing_bitmap <= convertible_pixels(T, rgb(uint8)).

:- implementation.

:- import_module int, list.

:- pragma foreign_decl("C#", "
    using System;
    using IronSoftware.Drawing;
    using System.Linq;
").

save_bmp(Filename, Image, !IO) :-
    Bitmap = to_foreign_bitmap(Image),
    save_foreign_bitmap(Filename, Bitmap, !IO).


:- func rgb_bitmap(image(rgb(uint8))) = foreing_bitmap.
:- pragma foreign_proc("C#", rgb_bitmap(Image :: in) = (Bitmap :: out),
    [promise_pure, may_call_mercury], 
"
    var arr = Image.pixel_array.Cast<pixel.Rgb_1>();
    var bytes = arr.SelectMany(rgb => new byte [] {(byte)rgb.red, (byte)rgb.green, (byte)rgb.blue}).ToArray();
    Bitmap = AnyBitmap.LoadAnyBitmapFromRGBBuffer(bytes, Image.image_size.width, Image.image_size.height);
").

:- pred save_foreign_bitmap(string::in, foreing_bitmap::in, io::di, io::uo) is det.
:- pragma foreign_proc("C#", save_foreign_bitmap(Filename::in, Bitmap::in, _IO1::di, _IO2::uo), [promise_pure],
"
    Bitmap.SaveAs(Filename);
"
).


to_foreign_bitmap(Img) = Bitmap :- (
    RGB = map(convert_pixel, Img),
    Bitmap = rgb_bitmap(RGB)
).


% main(!IO) :-
%     if 
%         image.from_lists([
%             [0u8, 255u8],
%             [255u8, 0u8]
%         ], Image)
%     then
%         ImageRGB = map(convert_pixel, Image),
%         Bitmap = rgb_bitmap(ImageRGB),
%         io.write_line(Bitmap, !IO)
%     else io.write_string("Error", !IO).