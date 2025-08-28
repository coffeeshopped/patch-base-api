---
title: JSONPatchTruss
---

A truss to define a patch that is backed by a JSON document, rather than a byte array. Useful when you need to define your own custom settings for an editor that don't correspond to anything stored on the synth itself.

<rule>
{
  json: String,
  parms: [::Parm::],
}
</rule>

<dl>
  <dt>json</dt>
  <dd>Truss ID</dd>
  <dt>parms</dt>
  <dd>specifies the parameters of the patch, including the paths, value ranges, and basic info for reading and writing parameter values from the byte array</dd>
</dl>

<rule>"channel"</rule>

A simple JSON-backed patch for storing a single MIDI Channel value. The stored value is in the range of 0–15 and displayed as 1–16.
