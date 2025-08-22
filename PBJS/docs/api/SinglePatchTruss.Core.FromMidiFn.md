Function that generates a byte array from a sequence of one or more MIDI messages.

rule:
\[">", [[SinglePatchTruss.Core.FromMidiFn]], [[ByteTransform]]...\]

Creates a FromMidiFn using the second array element (after the ">"), then feeds the output of that FromMidiFn to a series of one or more [[ByteTransform]]s in succession to generate the final

rule:
[[ByteTransform]]

A FromMidiFn is created that first flattens all the bytes of the incoming MIDI messages into a single byte array, then feeds that array into the parsed ByteTransform.

rule:
\[[[SinglePatchTruss.Core.FromMidiFn]]\]

Creates a single FromMidiFn that feeds MIDI messages into each of the individual FromMidiFn's in the array, and takes all of the outputs and concatenates them as a single byte array.