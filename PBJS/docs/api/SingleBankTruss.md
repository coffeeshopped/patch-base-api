---
title: SingleBankTruss
---

rule::validSizes

Used to specify a bank of patches that is stored as a series of sysex messages, usually one message per patch. This style of bank is usually possible to update on the synth in a piecemeal fashion; a single patch in the bank can be changed at a time.

<dl>
  <dt>singleBank</dt>
  <dd>The ::SinglePatchTruss:: that defines the individual patches contained in this bank.</dd>
  <dt>patchCount</dt>
  <dd>The number of patches contained in a single bank.</dd>
  <dt>locationIndex</dt>
  <dd>Given a sysex message (as an array of bytes) that represents a single patch from a bank, `locationIndex` is the index of that byte array that holds the value used as this patch's location in that bank. This value is used when parsing a set of MIDI messages that represents a bank, to determine where each patch belongs within the bank.</dd>
  <dt>validSizes</dt>
  <dd>An array of valid sizes (in bytes) for a bank. The string 'auto' can be included to specify that the automatically-calculated size for the bank is also valid. The automatically calculated size of a bank is `patchCount` times the size of a single patch.</dd>
  <dt></dt>
  <dd></dd>
</dl>  


rule::bundle

Same as above, except a ::ValidBundle:: is passed for more advanced validity checking on patches.


rule::compactSingleBank

Used to specify a bank of patches that are sent all at once to the synth (hence "compact"). This style of bank cannot accept changes to a single patch at a time; in order to update the bank on the synth, an entire bank must be sent.