---
title: MidiMessage
---

Specifies a MIDI message.

rule::syx

Specifies a sysex message. The byte array is used as the raw data for the sysex message, thus it should begin with `0xf0` and end with `0xf7`.

rule::240

An array that starts with the value `0xf0` (240) will be interpreted as the raw bytes to be sent in a Sysex Exclusive (sysex) message. 

rule::pgmChange

Specifies a MIDI Program Change message. The first byte is the MIDI channel (0-15) and the second byte is the program change value.