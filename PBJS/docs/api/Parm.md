---
title: Parm
---

A Parm is the representation of a single parameter within a synth patch. It specifies the path used to access that parameter's value within the patch, the information about how that parameter value is written to and read from the body byte array of the patch, the valid value ranges for the parameter, and any information used in the construction of MIDI messages to perform updates to that parameter's value.

\[ [[SynthPath]], {  
  b: Int?,  
  p: Int?,  
  bits: Range?,  
  bit: Int?,  
  packIso: [[PackIso]]?,  
  [[Span]] attributes...  
} \]

* **SynthPath**: The path of this parameter. Used for getting and setting the value of the parameter within a patch.
* **b**: The byte index of this parameter's value within a patch body's byte array.
* **p**: The parameter index. Often used in the process of sending an individual parameter update via MIDI.
* **bits**: The bit indices that this parameter's values are stored in within a byte. Used in situations where more than one parameter value is stored within a single byte
* **bit**: The bit index of the parameter value (for parameters that have a value of only 0 or 1)
* **packIso**: The [[PackIso]] used to get and set this parameter value. Most parameters can simply specify a byte index using *b*. But when a parameter spans multiple bytes, or uses a custom mapping function, a PackIso can be used to specify this logic.
* **[[Span]] attributes**: additional attributes that specify the [[Span]] of this parameter (e.g. the valid value range, or the textual meanings of various numerical values of this parameter).

## \[Parm\]

Rules that generate arrays of Parm's.

### { prefix: [[SynthPath]], count: Int, bx: Int?, px: Int?, block: \[Parm\] }

Takes *block* as an input array of Parm's, and outputs *count* copies of that array. The path of each Parm is prefixed with the specified *prefix*, followed by a number representing the current iteration, starting from 0.

If *bx* is specified, then (bx * the current iteration count) will be added to each *b* value in the Parm array. Similarly if *px* is specified, the same will be done to each *p* value in the Parm array.

Example:

```
{ prefix: 'osc', count: 3, bx: 5, block: [
  ['wave', { b: 2, opts: ["Tri", "Saw"] }],
  ['pitch', { b: 3 }],
] }

... will create:

[
  ['osc/0/wave', { b: 2, opts: ["Tri", "Saw"] }],
  ['osc/0/pitch', { b: 3 }],
  ['osc/1/wave', { b: 7, opts: ["Tri", "Saw"] }],
  ['osc/1/pitch', { b: 8 }],
  ['osc/2/wave', { b: 12, opts: ["Tri", "Saw"] }],
  ['osc/2/pitch', { b: 13 }],
]
```

### { prefix: [[SynthPath]], block: \[Parm\] }

Takes *block* as an input array of Parm's, and outputs a copy of that array, with each path prefixed by *prefix*.

### { inc: Int, block: \[Parm\], b: Int?, p: Int? }

Used to auto-generate a sequence of *b* and/or *p* values for an array of Parm's. *inc* specifies the amount to increment by for each Parm, and *b* and *p* specify the starting values of those respective properties.

Example:

```
{ inc: 1, b: 23, p: 11, block: [
  ['wave', { }],
  ['pitch', { }],
  ['pw', { }],
] }

... will create:

[
  ['wave', { b: 23, p: 11 }],
  ['pitch', { b: 24, p: 12 }],
  ['pw', { b: 25, p: 13 }],
]

```

### { offset: \[Parm\], b: Int?, p: Int? }

Takes *offset* as an input array of Parm's and outputs a copy, with the p and/or b values of each Parm offset by the amount specified.

Example:

```
{ b: 34, offset: [
  ['wave', { b: 0, p: 9 }],
  ['pitch', { b: 1, p: 21 }],
  ['pw', { b: 4, p: 13 }],
] }

... will create:

[
  ['wave', { b: 34, p: 9 }],
  ['pitch', { b: 35, p: 21 }],
  ['pw', { b: 38, p: 13 }],
]

```

### { b2p: \[Parm\] }

Takes the input array of Parm's and copies the *b* property of each Parm and writes it to the *p* property of that Parm (overwriting any existing *p* value if it exists).

Example:

```
{ b2p: [
  ['wave', { b: 0 }],
  ['pitch', { b: 1, p: 2 }],
  ['pw', { b: 4 }],
] }

... will create:

[
  ['wave', { b: 0, p: 0 }],
  ['pitch', { b: 1, p: 1 }],
  ['pw', { b: 4, p: 4 }],
]
