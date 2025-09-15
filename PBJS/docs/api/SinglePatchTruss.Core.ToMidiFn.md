---
title: SinglePatchTruss.Core.ToMidiFn
---

rule::ByteTransform

Take the input, process it through the ByteTransform, and treat the output as a single sysex MIDI message.

rule::>

The input should be a series of one or more ByteTransforms, with the last element of the array being a ToMidiFn (which itself can be just a ByteTransform). The input is processed through the first ByteTransform, with that output being fed as the input to the next ByteTransform, etc, and finally processed through the last ByteTransform to create one or more MidiMessages.

rule::yamFetch

A typical fetch request message for many Yamaha synthesizers. The first ByteTransform passed should yield the MIDI channel number for the request. The second ByteTransform should yield the command bytes for the request. The output MidiMessage will be:

```
[0xf0, 0x43, 0x20 + channel, cmdBytes, 0xf7]
```

rule::yamParm

A typical parameter change message for many Yamaha synthesizers. The first ByteTransform passed should yield the MIDI channel number for the request. The second ByteTransform should yield the command bytes for the request. The output MidiMessage will be:

```
[0xf0, 0x43, 0x10 + channel, cmdBytes, 0xf7]
```

rule::yamCmd

rule::yamSyx

rule::pgmChange

rule::[SinglePatchTruss.Core.ToMidiFn]

