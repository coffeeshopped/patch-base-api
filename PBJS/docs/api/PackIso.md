---
title: PackIso
---


Specifies the packing and unpacking (setting and getting) of parameter values to/from the body byte array of a patch.

<rule>["splitter", [::PackIso.Blitter::]]</rule>

Splits a single parameter value across multiple bytes in the body byte array. Each ::PackIso.Blitter:: specifies which bits of the value are read, and then written to the specified byte index location (and optional specific bits within the destination byte location).
