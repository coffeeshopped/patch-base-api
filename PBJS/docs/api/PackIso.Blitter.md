---
title: PackIso.Blitter
---

The specification for how a parameter value, that will be written across multiple bytes, is mapped to a single byte in the body byte array. 

<rule>
{
  byte: Int,
  byteBits: ::Range::?,
  valueBits: ::Range::,
}
</rule>

The incoming parameter value will be written as follows: The bits in the *valueBits* range will be read, and they will be written to the index specified by *byte*. If *byteBits* is present, the value bits will be written to that bit range in the destination byte. Otherwise, the value bits will be written starting at the least-significant bit.
