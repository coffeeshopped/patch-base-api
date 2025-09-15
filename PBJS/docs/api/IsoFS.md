---
title: IsoFS
---

rule::>

One or more IsoFF's should be given, and the final element of the array can optionally be an IsoFS. The input is fed to the first Iso, and that output is fed to the next Iso, and so on until the end. The final output is a String given by either the given IsoFS, or by converting the final IsoFF output to a String if no IsoFS is given.

rule::IsoFF

The given IsoFF is used to process the input, and the output number is converted to a String.

rule::concat

One or more IsoFS's should be given. The input is fed to each of the given IsoFS's, and the output Strings of all of them are concatenated together.

rule::noteName

Map a number of a note name in the form of Note+Octave, e.g. C2 or F#3. The given string should be the note name used for an input value of 0.

rule::str

Converts the input number to a formatted String, using the given String as a sprintf-style format string. If no String is specified, the format string is "%g".

rule::units

Formats the number as a String, with the given String concatenated to the end.

rule::@

Truncates the input value to an Int, and uses that value as an array index. The value at that index in the input array of Strings is returned.

rule::String

For any input, out the given String.

rule::switch

Allows for different Isos to be used depending on the range of the input value, e.g. a value between 0 and 5 will be fed to Iso A, whereas a value 6 to 10 will be fed to Iso B. The ranges and associated Isos are specified as ::IsoFS.SwitcherCheck::'s. The final optional Iso is the default Iso used if the input value is out of range of all of the checks. If not specified, it defaults to "=".

rule::baseSwitch

Similar to `switch` except that the value send to a given ::IsoFF.SwitcherCheck:: will be the input value *minus* the minimum range value of that SwitcherCheck. E.g. a SwitcherCheck with an input range from 5 to 10, given an input value of 6, will subtract 5 from that value, feeding the value 1 to the Iso for that range. `baseSwitch` is useful for parameters that have different Isos for different ranges, and each of those range Isos are most easily constructed as something that receives a minimum value of 0 (rather than whatever the minimum value for that input range might be).