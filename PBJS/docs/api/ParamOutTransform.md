---
title: ParamOutTransform
---

<rule>["bankNames", ::SynthPath::, ::SynthPath::]</rule>

Pulls the list of current patch names from the bank at the first specified SynthPath, and maps them to a ::Parm:: having the second specified SynthPath.

<rule>["patchOut", ::SynthPath::, Function]</rule>

Pulls one or more values from the section of the synth specified at the SynthPath and passes them through the supplied Function which returns an array of ::Parm::'s. The supplied Function should have the signature:

```
(PatchChange, SysexPatch) => [Parm]
```
