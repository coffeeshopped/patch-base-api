---
title: MultiPatchTruss.Core.ToMidiFn
---

rule::basic

First, get the body data from the MultiPatch that is located at the given path. Then, process that data through the supplied SinglePatchTruss ToMidiFn.

rule::[MultiPatchTruss.Core.ToMidiFn]

Pass the body data of the MultiPatch through each of the passed ToMidiFn's, and concatenate the results of all of them.

rule::UInt8

Returns a MidiMessage that is just the single byte value. TODO: is this used?

rule::Function

The function should have the signature ([[SynthPath:Byte]], Editor) => [MidiMessage]