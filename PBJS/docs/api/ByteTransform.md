---
title: ByteTransform
---
A function that takes in a byte array and optionally an Editor object and outputs a byte array.

rule::>

Creates a ByteTransform that takes the output byte array from the first ByteTransform, and feeds it to the next ByteTransform, etc. The same Editor object is fed to each ByteTransform in the series.

rule::b

A ByteTransform that simply outputs the input byte array.

rule::UInt8

A ByteTransform that outputs the given Number in a one-element Array.

rule::e.values

Extract an array of values from the Editor object. The first SynthPath specifies the editor section to pull from (e.g. "voice" to pull from the temporary voice section). The following Array of SynthPath's specifies the parameter paths to pull values from. The Function signature should be (Int) -> Int, and each pulled value will be put through this Function. The final output is an array of the mapped values.

rule::byte

Extract a single byte from the byte array, at the index specified by the Number. Output the byte as a one-element array. Throws an error if the index is out of range.

rule::bytes

Extract a series of bytes from the byte array. The passed Object should have a *start* property that specifies the beginning index to parse from. A negative value for *start* specifies an index starting from the end of the array (e.g. -1 specifies that last byte of the array). Additionally the Object should either have a *count* property that specifies the number of bytes to extract, or an *end* property that indicates the final index to extract from.

Throws an error if the calculated *end* index is less than or equal to *start*.

0-values are returned for any out-of-range indices.


rule::bits

Extracts the bits specified by the Range as a Byte, which is output as a single-element array. The first byte from the input byte array will be used as input. The input byte array can be specified as the last element, or omitted in which case the input byte array for the function will be passed.

Bit indices are 0-based, with 0 specifying the least-significant bit of the byte.


rule::bit

Extracts the single bit specified at the passed index. Similar to "bits", but for just a single bit.

rule::msBytes7bit

Decompose a value into a byte array, 7 bits at a time, MSB-first. The first Int passed is the value to be decomposed, and the second Int is the length of the resulting array.


rule::enc

Decompose a String into a series of bytes representing the Unicode values of the string.


rule::count

Return a one-element array containing the length of the input byte array.

rule::countDecomp

Get the length of the input byte array. Then, decompose that (length) value into a series of bytes, using the encoding specified by the String, with an array length (number of bytes) specified by the final Int.

rule::nibblizeLSB

Process the input ByteTransform, and output the result as a series of nibbles (4-bit values), least-significant bit first.

rule::denibblizeLSB

Process the input ByteTransform, taking 2 bytes at a time and combining them into a single byte, where the lower 4 bits of the first byte are the least significant bits of the output byte.


rule::checksum

Compute a checksum on the passed byte array, adding all values together and keeping the lower 7 bits of the result.


rule::yamChk

Compute a "Yamaha-style" checksum on the byte array, adding all values together, negating the result in 2's-complement format, then keeping just the lower 7 bits of the result.


rule::trussTransform

Translate the input byte array, reading it as body data in the format of the "from" SinglePatchTruss, and outputting a new array with those values mapped to the format of the "to" SinglePatchTruss. E.g. if the "from" truss has a parameter with path "osc/0/wave" at byte 5, and the "to" truss has the same parameter path, but at byte 8, then the byte value at index 5 of the input array will be output at byte index 8 in the output array. 


rule::EditorValueTransform

Parse as an ::EditorValueTransform::, and output the result as an array of bytes.

rule::array

Each ByteTransform is fed the same input byte array and Editor object, and the outputs of the ByteTransform's are concatenated and flattened.


rule::Function

Pass the input byte array as the sole argument to a Javascript function, which should output a byte array.
