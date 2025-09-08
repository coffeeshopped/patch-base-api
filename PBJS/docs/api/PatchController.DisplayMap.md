---
title: PatchController.DisplayMap
---

Used for mapping parameter values (from patches) to values used in a custom UI display, such as an envelope visualization.

rule::src

Maps the value at the first SynthPath to the Display parameter at the second SynthPath if given, otherwise to the same SynthPath, using the given Function.

rule::u

Maps the value at the first SynthPath, dividing it by the given Float value, and maps it to a Display parameter. If a second SynthPath is given, that is the Display parameter mapped to. Otherwise, map to a Display parameter at the same first SynthPath.

rule::uDefault

Same as above, but the Float to be divided by is 127.

rule::=

Passes the value from patch parameter to Display parameter, unchanged.