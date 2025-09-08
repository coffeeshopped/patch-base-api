---
title: MemSlot.Transform
---

Maps an index representing a location in a bank to a formatted slot name. For presets, it also maps the location to a patch name.

rule::user

Used for user-writable slots in a bank. The passed Function should have a signature (Int) -> String, which maps a bank location to a string that corresponds to how that "slot" is represented on the synthesizer. E.g. some synths may represent "slot 0" in a bank as "1" (a 1-based numbering instead of 0-based). Or, some may display the user-writeable bank with a text prefix such as "Int" (for Internal), and also use a 1-based numbering scheme, so in that case the function would be something like:

```
i => `Int-${i+1}`
```

... mapping location 0 to the string "Int-1".

rule::preset

Used for preset (non-user-writable) banks. The passed Function operates the same as for the "user" version (above), where an index is mapped to a String that matches how the synth represents that slot (e.g. "Pr-A 01" for Preset Bank A, location 0).

The passed array of strings are the preset patch names for that bank.
