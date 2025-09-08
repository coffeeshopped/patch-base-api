---
title: SingleBankTruss
---

rule::validSizes

<dl>
  <dt>singleBank</dt>
  <dd>The ::SinglePatchTruss:: that defines the individual patches contained in this bank.</dd>
  <dt>patchCount</dt>
  <dd>The number of patches contained in a single bank.</dd>
  <dt>locationIndex</dt>
  <dd>Given a sysex message (as an array of bytes) that represents a single patch from a bank, `locationIndex` is the index of that byte array that holds the value used as this patch's location in that bank. This value is used when parsing a set of MIDI messages that represents a bank, to determine where each patch belongs within the bank.</dd>
  <dt>validSizes</dt>
  <dd>...</dd>
  <dt></dt>
  <dd></dd>
</dl>  