:- module dicom_tags.

:- interface.
:- import_module dicom.

:- func rows = tag.
:- func columns = tag.

:- func bits_allocated = tag.
:- func bits_stored = tag.
:- func high_bit = tag.

:- func pixel_representation = tag.
:- func photometric_interpretation = tag.
:- func pixel_data = tag.

:- implementation.

rows = tag(0x0028u16, 0x0010u16).
columns = tag(0x0028u16, 0x0011u16).

bits_allocated = tag(0x0028u16, 0x0100u16).
bits_stored = tag(0x0028u16, 0x0101u16).
high_bit = tag(0x0028u16, 0x0102u16).

pixel_representation = tag(0x0028u16, 0x0103u16).
photometric_interpretation = tag(0x0028u16, 0x0004u16).
pixel_data = tag(0x7FE0u16, 0x0010u16).