---
title: EditorValueTransform
---

rule::e

Pulls a parameter value from the editor. The first SynthPath passed is used to determine the section of the synth to read from (e.g. "global", "voice", etc.). The second SynthPath is the path within that section that should be read. The final optional Int is used as a default value used when the editor value is not found.


rule::channel

A shortcut that specifies that the value of the first midi channel defined by the editor should be used. This corresponds to the first ::MidiTransform:: that was specified in the ::BasicEditorTruss::.