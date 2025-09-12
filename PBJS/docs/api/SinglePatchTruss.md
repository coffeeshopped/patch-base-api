---
title: SinglePatchTruss
---

The description of a patch composed of a single array of bytes. The byte array contains all parameter values (including patch name, if present).

rule::basic

<dl>
  <dt>single</dt>
  <dd>Truss ID</dd>
  <dt>initFile</dt>
  <dd>path to file used as an example "init" patch</dd>
  <dt>parms</dt>
  <dd>specifies the parameters of the patch, including the paths, value ranges, and basic info for reading and writing parameter values from the byte array</dd>
  <dt>pack</dt>
  <dd>a custom function for mapping parameter values into the byte array</dd>
  <dt>unpack</dt>
  <dd>a custom function for parsing parameter values out of the byte array</dd>
  <dt>parseBody</dt>
  <dd>function for extracting the byte array from a sequence of one or more MIDI messages (e.g. a file containing a sysex string)</dd>
  <dt>createFile</dt>
  <dd>function to create a sequence of one or more MIDI messages representing a patch from the byte array.</dd>
</dl>
