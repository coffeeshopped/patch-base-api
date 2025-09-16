---
title: Parm.Span
---

rule::rng

Specifies a value range for the parameter, with an optional "display offset" which is added to value before it is displayed on-screen.

rule::max

Same as `rng` but only specifies the maximum range value, with the minimum set to 0.

rule::dispOff

Sets a range of 0–127, with the specified display offset.

rule::opts

Parameter values are mapped to the corresponding element in the array.


rule::options

Similar to above. TODO: probably should be phased out and removed.

rule::iso

Sets the parameter range to the passed Range, or 0–127 if no Range is passed. Parameter values are passed to the given Iso, which will format the values for display

rule::isoMax

Same as above, except only a max value for the range is specified, with the minimum set to 0.

rule::Object

An empty JS object can be passed as a shortcut for `{ rng: [0, 127] }`.