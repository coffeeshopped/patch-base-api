---
title: IsoFF
---

An "Iso" defines a pair of functions that map between two types. Each function performs the inverse of the other function, with the first function being called "forward" and the second being called "backward". With any iso, if you apply the "forward" function to a value, then apply "backward" to the result, the result is the original value.

Iso's are primarily used in the context of parameter mapping, to map values as the synth understands them (numbers) to values as a human understands it (either a number, or a string). Iso's are useful because, via the specification of mapping from a "synth" value to a "human" value, you will also automatically define the mapping in the other direction ("human" to "synth"). Thus, you can use Iso's in ::Parm::s to specify how a patch parameter value should be shown on-screen, and automatically create the inverse logic that takes an input value from a user (in "human" units), and maps it to the correct patch parameter value.

Iso's are usually used in a "chain" to create a more complex mapping between values. There are also many system-defined Iso's for common mapping tasks.

IsoFF defines Iso's that map from a number to a number ("Float" to "Float"). ::IsoFS:: is used for mapping a number to a string.

rule::+

Add the input to the number specified.

rule::-

Subtract the number specified from the input.

rule::!-

Reverse subtraction. Subtract the input from the number specified. E.g. `["!-", 2]` will create a forward function `2 - input`.

rule::*

Multiply the input by the number specified.

rule::/

Divide the input by the number specified.

rule::round

Round the input to a given number of decimal places

rule::lerp

The first Range is used as the input range, and the second as the output range. Use linear interpolation to map the input value, as a position within the input range, to a value in the output range at the same position.

rule::=

Pass the input value through unchanged.

rule::switch

Allows for different Isos to be used depending on the range of the input value, e.g. a value between 0 and 5 will be fed to Iso A, whereas a value 6 to 10 will be fed to Iso B. The ranges and associated Isos are specified as ::IsoFF.SwitcherCheck::'s. The final optional Iso is the default Iso used if the input value is out of range of all of the checks. If not specified, it defaults to "=".

rule::baseSwitch

Similar to `switch` except that the value send to a given ::IsoFF.SwitcherCheck:: will be the input value *minus* the minimum range value of that SwitcherCheck. E.g. a SwitcherCheck with an input range from 5 to 10, given an input value of 6, will subtract 5 from that value, feeding the value 1 to the Iso for that range. `baseSwitch` is useful for parameters that have different Isos for different ranges, and each of those range Isos are most easily constructed as something that receives a minimum value of 0 (rather than whatever the minimum value for that input range might be).