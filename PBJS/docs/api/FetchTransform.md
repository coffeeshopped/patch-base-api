---
title: FetchTransform
---

<rule>["truss", ::SinglePatchTruss.Core.ToMidiFn::]</rule>

The editor will using the given ToMidiFn to construct a single MIDI message to send to the synth. The editor will expect a MIDI response with a total byte length that matches the corresponding SysexTruss at the same path as this FetchTransform.

The given ToMidiFn will be called with an empty byte array, and the current editor object, so that the returned MIDI message can be responsive to current editor settings (e.g. the current MIDI channel set for the editor).

Please note that this form of FetchTransform can be used for banks (not just patches) when the bank fetch is requested via a single MIDI message.

<rule>["bankTruss", ::SinglePatchTruss.Core.ToMidiFn::]</rule>

The editor will fetch a bank via multiple MIDI messages. Each MIDI message sent from Patch Base will represent the request for a single patch within the bank. The passed ToMidiFn will be called repeatedly, once for each patch, with a byte array consisting of a single byte for the current bank location being fetched (e.g. 0, then 1, then 2, etc) and the current editor object will also be passed to query the current MIDI channel, etc.

The number of MIDI messages sent will be equal to the number of patches specified in the BankTruss that corresponds to this path. Once all MIDI responses are received, they will be validated based on their total byte length, compared with the expected total byte length of the corresponding BankTruss.

<rule>["sequence", [FetchTransform]]</rule>

<rule>["custom", ...]</rule>
