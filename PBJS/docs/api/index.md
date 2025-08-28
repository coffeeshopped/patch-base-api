# Patch Base API Intro

The Patch Base API enables the creation of custom editors for an upcoming version of Patch Base.

You can specify all of the logic needed for a synth patch editor to create patches, send and receive patches and individual parameter changes, and manage patch banks for just about any MIDI-enabled hardware synthesizer. All of Patch Base's 80+ editors are being ported to this API. So if Patch Base does it, it can be done using this API, often with a relatively small amount of code!

To use the API, a collection of Javascript files should be created that specify the various data and functions needed. They can be broken down into a few main parts, as given later in this document.

The API attempts to be as declarative as possible, meaning that the majority of code for an editor simply defines objects and arrays in Javascript. Javascript Functions are used as sparingly as possible. For example, a simple voice patch description for an editor might look like this (with comments here for explanation):

```
{
  // It's a Voice patch, backed by a single array of bytes to store all of the values
  single: "voice",
  
  // The parameters of the patch are:
  parms: [
  
    // The waveform of the first oscillator, 
    // which is stored at byte index 10, and has 3 waveform options. 
    ['osc/0/wave', { b: 10, opts: ["Tri", "Saw", "Square"]}],
    
    // The pitch of the first oscillator, which can range from 0 to 127, 
    // and will be displayed to the user as a note name, 
    // with the value of 0 as "C0", 1 as "C#0", etc.
    ['osc/0/pitch', { b: 11, iso: ['noteName', 'C0'] }],
    
    ...
  ],
  
  // The name of the patch is stored in bytes 0-9 of the byte array
  namePack: [0, 9],
  
  // Given a sysex message representing the patch (e.g. from the synth), 
  // the editor should extract 204 bytes from that message, 
  // starting at byte index 5.
  // The resulting array holds all of the parameter values and patch name
  parseBody: ['bytes', { start: 5, count: 204 }],
  
  // To create a MIDI message to represent this patch to the synth, 
  // create a sysex message with the bytes [0xf0, 0x0f, 0x02], 
  // followed by the current MIDI channel selected in the editor, 
  // followed by 0x01, 
  // followed by the byte array that the editor is currently using to represent the patch, // followed by 0xf7. 
  // String all of those values together to create a sysex message for this patch 
  // (that can also be written to disk).
  createFile: [0xf0, 0x0f, 0x02, 'channel', 0x01, 'b', 0xf7],
}
```

Hopefully this illustrates that the API has been constructed to allow for straightforward, declarative representation of synth data, such that the creation of a patch editor is largely a process of translating the manufacturer's documentation of a synth's MIDI implementation to corresponding data structures that Patch Base understands.

The API was designed after the creation of 80+ synth editors in the past, and it condenses things as much as possible based on common needs and data representations found in various synthesizers. It strives to make the common case very succinct to express, while also allowing for flexibility when needed.


## Patch and Bank Trusses

These files specify the basic information about a synthesizer's patch(es) and banks, such as what all the parameters are for a voice patch, the valid value ranges for each parameter, where that parameter is stored within the byte memory of a patch's data, and how a patch can be written to or read from MIDI data.

The most commonly used type patch truss is ::SinglePatchTruss::, which specifies all of this information for a synthesizer patch that is stored as a single array of bytes, transmitted via a single sysex message.

More complicated synth patches might be represented using ::MultiPatchTruss::, such as many Roland rompler synth patches where there are separate parts for the "common" data (overall patch data) and the individual "tone" parts (e.g. 4 different sample-based voices each with its own envelopes, sample selection, etc).

## BasicEditorTruss

The editor truss is the top-level object that holds all of the data and logic for communicating with a synthesizer and representing the synth's memory. This is all represented as a ::BasicEditorTruss::.

This object contains all of the Patch and Bank trusses, with a ::SynthPath:: specifying the path for each of these areas of the synth. The object also specifies the logic for fetching patches or banks from the synth (::FetchTransform::), sending MIDI data to the synth for patch and bank transmission (::MidiTransform::), logic for which MIDI channels should be used for communication (::MidiChannelTransform::), logic for naming bank memory slots (::MemSlot.Transform::), and any cross-mapping of data between areas of the synth that enable richer UI controllers (::ParamOutTransform::).

## PatchController

::PatchController::'s are the specification for the actual user interface of the editor. They define the on-screen controls that interact with the parts of the BasicEditorTruss to allow for parameter changes, name changes, etc. The PatchController objects contain several parts, such as ::PatchController.Builder:: objects to specify the panel containers, ::PatchController.PanelItem::'s which define the individual controls within the panels, ::PatchController.Effect::'s which specify relationships between the patch data changes and UI changes (e.g. dimming certain controls when certain parts of a patch are not active), ::PatchController.Constraint:: objects which define the visual layout of the panels within the controller, and ::PatchController.Display::'s which allow for the creation of custom data visualizations (such as envelope displays).

## BasicModuleTruss

::BasicModuleTruss:: is the very top-most-level object for a Patch Base editor. It holds the ::BasicEditorTruss:: as well as arrays of ::ModuleTrussSection.Item::'s which in turn hold ::PatchController:: instances and maps them to the different areas of the ::BasicEditorTruss::.