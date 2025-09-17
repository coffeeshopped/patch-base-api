---
title: SynthPathMap
---

A function that maps an input array of ::SynthPath::'s to another array.


rule::removePrefix

For any SynthPath that starts with the specified prefix, remove that prefix and return what's left. For any SynthPath that does not start with that prefix, return nothing.

Example:

```
["removePrefix", 'osc/0']

... when used on: 

['osc/0/wave', 'amp/env', 'osc/0/pitch/1']

... will output:

['wave', 'pitch/1']
```


rule::from

Return the subpath for each SynthPath, starting from the specified (0-based) index.

Example:

```
["from", 2]

... when used on: 

['osc/0/wave', 'amp/env', 'osc/0/pitch/1']

... will output:

['wave', 'pitch/1']
```


rule::fn

Map each SynthPath through an arbitrary Javascript Function.
