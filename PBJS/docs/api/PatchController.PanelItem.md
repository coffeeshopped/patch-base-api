---
title: PatchController.PanelItem
---

This type pairs together a UI element (a control, or display) with an optional ID that can be automatically mapped to a patch parameter.

rule::basic

TODO: probably change this rule to be Object based rather than Array.

rule::dynamic

Create a dynamic control that adapts to the parameter to which it is mapped. E.g. a numeric parameter will map to a Knob, whereas a parameter with text-based options might map to a Select, or to a Switch if it only has a small number of options.

rule::-

Create a spacer item with a width of 2.