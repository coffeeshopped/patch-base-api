---
title: PatchController.AttrChange
---

rule::dimItem

"Dim" (make semi-transparent) the PanelItem specified by SynthPath. If the Bool is false, the alpha transparency is set to 1 (opaque). The optional Float specifies a specific alpha value to be used when the item is dimmed. It is recommended to just use the default transparency value, unless some specific functionality is needed.

rule::hideItem

Hide the PanelItem specified by SynthPath. This is the same as using `dimItem` with a transparency value of 0.

rule::dimPanel

"Dim" (make semi-transparent) the panel specified by the String. If the Bool is false, the alpha transparency is set to 1 (opaque). If no String is passed as an identifier, the entire controller is dimmed. The optional Float specifies a specific alpha value to be used when the panel is dimmed. It is recommended to just use the default transparency value, unless some specific functionality is needed.


rule::hidePanel

Hide the panel specified by the String (or the entire controller, if no String is passed). This is the same as using `dimPanel` with a transparency value of 0.


rule::setIndex

Set the index of the specified controller. If no String is passed as an identifier, the index of the current controller is set.

rule::setCtrlLabel

Set the label of the control specified by the ::SynthPath::.

rule::configCtrl

Configure the control specified by the SynthPath.


rule::setValue

Set a value, local to the controller. No value change is communicated to the SynthEditor itself. If the passed SynthPath matches a PanelItem, that item's value will be updated. Can be useful for advanced controller logic where multiple controls interact with each other.


rule::colorItem

Set the color of the PanelItem specified by SynthPath to the specified color level (1 by default). The Bool specifies whether the background of the item should be set to clear or not.


rule::basicParamsChange

Send a basic parameter change message up to the SynthEditor (which in turn triggers any necessary communication with the synth hardware and updates the internal patch data of the editor). The SynthPath specifies the path of the parameter to change (and will be prefixed by any parent controller prefixes that have been set). The Int is the value the parameter should be set to.

rule::paramsChange

Send a parameter change message up to the SynthEditor (same as the rule above), but with multiple parameters and values specified.


rule::[SynthPath:Int]

Send a parameter change with multiple parameters and values. TODO: This rule might cause parsing errors. Might need to remove.


rule::setNavPath

Set the path of a NavButton PanelItem. These buttons are used as controls to open different parts of a synth editor (e.g. a button within a Performance editor to open the editor for a specific Voice part). Use `setNavPath` to dynamically set the path opened by a NavButton.


rule::midiNote

Send a MIDI note out to the synth. The arguments are: MIDI Channel, pitch, velocity, and duration (in milliseconds).

## [PatchController.AttrChange]

rule::array.single

This rule allows for a single AttrChange to be specified in places where an array of AttrChanges is expected (for convenience).