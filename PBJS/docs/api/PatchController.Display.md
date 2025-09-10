---
title: PatchController.Display
---

Built-in data display elements.

rule::dadsrEnv

An envelope display with 5 parameters: delay, attack, decay, sustain, release.

rule::timeLevelEnv

A time/level envelope display.

<dl>
  <dt>timeLevelEnv</dt>
  <dd>Not used, but the key must be present to specify this rule.</dd>
  <dt>pointCount</dt>
  <dd>The number of time/level points in the display.</dd>
  <dt>sustain</dt>
  <dd>The sustain point of the envelope (if any). Should be 0-based. Set to a number greater than the `pointCount` to have no sustain point.</dd>
  <dt>bipolar?</dt>
  <dd>Set to true if this envelope can have negative level values, so that the display will be drawn with the X-axis vertically centered, rather than at the bottom of the display.</dd>
</dl>  

rule::env

A custom display element (usually for an envelope). The passed function should have the signature <code>([SynthPath:Float]) => [::PBBezier.PathCommand::]</code>. Whenever the display is updated, a dictionary will be passed to the function containing various parameter values. The function uses those to return an array of drawing functions which will be used to draw a bezier path within the display.

rule::levelScaling

A Level Scaling display, used for the Yamaha DX7 and related synths.