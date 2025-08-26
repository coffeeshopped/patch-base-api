---
title: BasicEditorTruss
---

The top-level object that defines a synth editor. It includes all of the data and logic for reading and writing the various patches and banks, communicating changes to the synth via MIDI, and any extra logic needed for enhanced behavior within the editor UI (but not the code for the UI itself, which is part of the SynthModule).

<rule>
{
  name: String,
  trussMap: [[::SynthPath::, ::SysexTruss::]],
  fetchTransforms: [[::SynthPath::, ::FetchTransform::]],
  midiOuts: [[::SynthPath::, ::MidiTransform::]],
  midiChannels: [[::SynthPath::, ::MidiChannelTransform::]],
  slotTransforms: [[::SynthPath::, ::MemSlot.Transform::]]?,
  extraParamOuts: [::ParamOutTransform::]?,
}
</rule>

<dl>
  <dt>name</dt>
  <dd>A string to identifier this synthesizer</dd>
  <dt>trussMap</dt>
  <dd>A dictionary (defined as an array of 2-element arrays) mapping paths to memory areas of the synthesizer, such as the temporary edit buffer for voice, the voice bank, the temporary edito buffer for a performance, etc.</dd>
  <dt>fetchTransforms</dt>
  <dd>A dictionary mapping paths to ::FetchTransform::'s which define the communication logic needed to fetch the data for that corresponding synth section into Patch Base.</dd>
  <dt>midiOuts</dt>
  <dd>A dictionary mapping paths to ::MidiTransforms::'s which define the communication logic needed to send updates to the synthesizer such as individual parameter changes, full patch dumps, and bank edits.</dd>
  <dt>midiChannels</dt>
  <dd>A dictionary mapping paths to ::MidiChannelTransform::'s, which tell the editor which MIDI channel should be used to play notes for a given section of the synthesizer/editor.</dd>
  <dt>slotTransforms</dt>
  <dd>A dictionary mapping paths to ::MemSlot.Transform::'s, which tell the editor how to map a bank location/index to a patch name; either a preset patch name, or the name of the patch currently stored at that location on the synthesizer.</dd>
  <dt>extraParamOuts</dt>
  <dd>An array of ::ParamOutTransform::'s which cross-map data between the sections of the synthesizer, for easy access by controllers in the UI. A common example of this is mapping the current name list of patches in the Voice Bank to a parameter that is accessible in the "Performance" section of the editor, so that the Performance editing UI can display a current list of patch options for selection.</dd>
</dl>

<rule>
{
  rolandModelId: [Byte],
  addressCount: Int,
  name: String,
  map: [::RolandEditorTrussWerk.MapItem::],
  deviceId: ::EditorValueTransform::?,
  midiChannels: [[::SynthPath::, ::MidiChannelTransform::]],
  slotTransforms: [[::SynthPath::, ::MemSlot.Transform::]]?,
  extraParamOuts: [::ParamOutTransform::]?,
}
</rule>
