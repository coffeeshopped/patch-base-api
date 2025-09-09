---
title: ModuleTrussSection.Item
---

Each item specifies an area of the editor, with a graphical interface specified by a ::PatchController:: (or bank editor), connected to a specified area of the synth, specified by a ::SynthPath:: (or implied based on the rule used).

rule::global

Connects the passed controller to the area of the synth specified by the path "global". By default this section is titled "Global", but a title can optionally be specified.

rule::voice

Connects the passed controller to the area of the synth specified by the path "voice" (or a different SynthPath if one is passed). The item is titled with the given String. The controller will be given the default in-app keyboard.

rule::perf

Connects the passed controller to the area of the synth at path "perf". The item will be titled "Performance", and the controller will be given an in-app keyboard with selectable MIDI channel. An optional object can be passed to override title and/or path.

rule::bank

Creates a Bank Editor controller with the given title, and connected to the given path.

rule::channel

Creates a simple controller, connected to the synth's "global" area, with a single knob that is mapped to a ::Parm:: with the path "channel".

rule::deviceId

Same as the "channel" rule above, but mapped to a ::Parm:: with the panel "deviceId".

rule::custom

Maps the controller to the given path, with the given title. No in-app keyboard is added to the controller.


## [ModuleTrussSection.Item]

Rules that create arrays of ModuleTrussSection.Item

rule::array.perfParts

Creates multiple copies of the passed controller. The number is specified as the second argument. Each controller is connected to the path "part/i" where "i" is a number from 0 upwards. The given Function should take a single Int and return a title for the item, e.g.

```
i => `Part ${i + 1}`
```

rule::array.banks

Creates multiple items, each with a bank editor. The Function creates the title for each item, similar to the "perfParts" rule above. The passed ::SynthPath:: is used as a prefix followed by a number, and connects to the corresponding part of the synth. E.g.

```
["banks", 3, i => `Voice Bank ${i + 1}`, 'bank/voice']
```

... would create 3 bank editor controllers, titled "Voice Bank 1", "Voice Bank 2", etc and connected to the paths "bank/voice/0", "bank/voice/1", etc.

