---
title: SynthPath
---

Used to specify paths in various areas of an editor, such as parameter paths within a single patch, and paths to the different sections of an editor.

### String

A string will be split into multiple items using the "/" character. E.g. `osc/0/wave` becomes `['osc', 0, 'wave']`.

### Int

A single Int will translate to a single-element path containing that Int. E.g. `0` becomes `[0]`.

### Array

An array of elements is flattened into a single path. E.g. `['osc', [0, 'wave']]` becomes `['osc', 0, 'wave']`.

## \[SynthPath\]

Rules that generate arrays of SynthPath's.

### \['>', \[ [[Parm]] \], [[SynthPathMap]], [[SynthPathMap]], ... \]

Takes an array of Parm's and extracts the paths from them as a new array. That array is then fed in sequence through each following SynthPathMap to form the final output array of SynthPath's.

Useful in Controllers when a subset of parameter paths is needed for bulk actions (e.g. copy/paste).