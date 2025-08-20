A function that takes in a byte array and optionally an Editor object and outputs a byte array.

### \[">", [[ByteTransform]], [[ByteTransform]]...\]

Creates a ByteTransform that takes the output byte array from the first ByteTransform, and feeds it to the next ByteTransform, etc. The same Editor object is fed to each ByteTransform in the series.

### "b"

A ByteTransform that simply outputs the input byte array.

### Number

A ByteTransform that outputs the given Number in a one-element Array.

### \["e.values", [[SynthPath]], \[[[SynthPath]]\], Function\]

Extract an array of values from the Editor object. The first SynthPath specifies the editor section to pull from (e.g. "voice" to pull from the temporary voice section). The following Array of SynthPath's specifies the parameter paths to pull values from. The Function signature should be (Int) -> Int, and each pulled value will be put through this Function. The final output is an array of the mapped values.

### \["byte", Number\]

Extract a single byte from the byte array, at the index specified by the Number. Output the byte as a one-element array. Throws an error if the index is out of range.

### \["bytes", { start: Int, ... }]

Extract a series of bytes from the byte array. The passed Object should have a *start* property that specifies the beginning index to parse from. A negative value for *start* specifies an index starting from the end of the array (e.g. -1 specifies that last byte of the array). Additionally the Object should either have a *count* property that specifies the number of bytes to extract, or an *end* property that indicates the final index to extract from.

Throws an error if the calculated *end* index is less than or equal to *start*.

0-values are returned for any out-of-range indices.

### \["bits", Range, \[UInt8\]?\]

Extracts the bits specified by the Range as a Byte, which is output as a single-element array. The first byte from the input byte array will be used as input. The input byte array can be specified as the last element, or omitted in which case the input byte array for the function will be passed.

Bit indices are 0-based, with 0 specifying the least-significant bit of the byte.

### \["bit", Int, \[UInt8\]?\]

Extracts the single bit specified at the passed index. Similar to "bits", but for just a single bit.

### \["msBytes7bit", Int, Int\]

Decompose a value into a byte array, 7 bits at a time, MSB-first. The first Int passed is the value to be decomposed, and the second Int is the length of the resulting array.

### \["enc", String\]

Decompose a String into a series of bytes representing the Unicode values of the string.

### "count"

Return a one-element array containing the length of the input byte array.

### \["count", ByteTransform, String, Int\]

Process the ByteTransform, then get the length of the resulting byte array. Then, decompose that (length) value into a series of bytes, using the encoding specified by the String, with an array length (number of bytes) specified by the final Int.

### \["nibblizeLSB", ByteTransform?\]

Process the input ByteTransform, and output the result as a series of nibbles (4-bit values), least-significant bit first.

    .a(["denibblizeLSB", ".x?"], {

      .arg1(**try** $0.xq(1) ?? .ident) { bytes **in**

        (bytes.count / 2).map {

          UInt8(bytes[$0 * 2].bits(0...3) + (bytes[$0 * 2 + 1].bits(0...3) << 4))

       }

      }

    }),

    .a(["checksum", ".x?"], {

      .arg1(**try** $0.xq(1) ?? .ident) {

        [UInt8($0.map{ Int($0) }.reduce(0, +) & 0x7f)]

      }

    }),

    .a(["yamChk", ".x?"], {

      .arg1(**try** $0.xq(1) ?? .ident) {

        [Yamaha.checksum(bytes: $0)]

      }

    }),

    .a(["trussTransform", ".d"], {

      **let** obj = **try** $0.obj(1)

      **let** fromTruss: SinglePatchTruss = **try** obj.x("from")

      **let** toTruss: SinglePatchTruss = **try** obj.x("to")

      **return** **try** .arg1(**try** $0.xq(2) ?? .ident) {

        **try** toTruss.parse(otherData: $0, otherTruss: fromTruss)

      }

    }),

    .s(".s", {

      // if string, see if it's an editorValueTransform

      **let** evt: EditorValueTransform = **try** $0.x()

      **return** .e { [**try** evt.byteValue($0)] }

    }),

    .s(".a", {

      // first see if it's an EVT

      **if** **let** evt = **try**? $0.x() **as** EditorValueTransform {

        **return** .e { [**try** evt.byteValue($0)] }

      }

      **let** fns: [**Self**] = **try** $0.map { **try** $0.x() }

      **return** .fn { b, e **in**

        **try** fns.flatMap { **try** $0.call(b, e) }

      }

    }),

    .s(".f", { fn **in**

      **let** exportOrigin = fn.exportOrigin()

      **return** .b { b **in** **try** fn.call([b], exportOrigin: exportOrigin).x() }

    }),