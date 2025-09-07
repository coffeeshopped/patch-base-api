---
title: RxMidi.FetchCommand
---

Specifies individual commands used during the patch or bank fetch process, including sending MIDI data out, with or without expecting a MIDI response, and waiting a specified amount of time.

rule::send

Sends the specified MidiMessage out to the synth, and does not wait for a response before executing the next fetch command.