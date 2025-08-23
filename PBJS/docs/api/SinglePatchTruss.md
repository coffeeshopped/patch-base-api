---
title: SinglePatchTruss
---

The description of a patch composed of a single array of bytes. The byte array contains all parameter values (including patch name, if present).

{  
  single : String,  
  initFile : String,  
  parms : \[ [[Parm]] \],  
  pack : [[SinglePatchTruss.PackFn]]?,  
  unpack : [[SinglePatchTruss.UnpackFn]]?,  
  parseBody : [[SinglePatchTruss.Core.FromMidiFn]]?,  
  createFile : [[SinglePatchTruss.Core.ToMidiFn]]?,  
}

* **single**: Truss ID
* **initFile**: path to file used as an example "init" patch
* **parms**: specifies the parameters of the patch, including the paths, value ranges, and basic info for reading and writing parameter values from the byte array
* **pack**: a custom function for mapping parameter values into the byte array
* **unpack**: a custom function for parsing parameter values out of the byte array
* **parseBody**: function for extracting the byte array from a sequence of one or more MIDI messages (e.g. a file containing a sysex string)
* **createFile**: function to create a sequence of one or more MIDI messages representing a patch from the byte array.
