---
title: PatchController.Prefix
---

Specifies a path prefix (a SynthPath) for a controller. All parameter SynthPaths for the controller will be prefixed by this value, giving a way to scope all of the controls in a given controller to a parent SynthPath.

rule::index

Specify a SynthPath that will have the current controller index value appended to it, and then used as the prefix for the controller. The index value for a controller can be changed via a `switcher` ::PatchController.PanelItem::. Example: you're creating a controller to change the oscillator settings for a patch. The synth has 3 identical oscillators. `{ index: 'osc' }` will set the prefix of the controller to be `osc/0`. If the controller has a `switcher` control, and the second tab of the switcher is selected, the controller's prefix will change to `osc/1`.

rule::fixed

Set the prefix of this controller to a fixed value.

rule::indexFn

When the index of this controller changes, the index value will be passed to the given Function, which should return a SynthPath value that will be used as the controller's new prefix.