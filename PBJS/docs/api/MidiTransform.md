---
title: MidiTransform
---

rule::singlePatch

Used with SinglePatchTrusses that can have individual parameter changes sent to the synth (as opposed to some synths that only accept full patch dumps.)

<dl>
  <dt>throttle</dt>
  <dd>Minimum time in milliseconds that Patch Base should wait between sending MIDI data to the synth.</dd>
  <dt>param</dt>
  <dd>The logic for sending individual parameter changes to the synth.</dd>
  <dt>patch</dt>
  <dd>The logic for sending entire patch dumps to the synth. Used when loading a new patch, and also when changes to multiple parameters occur very quickly.</dd>
  <dt>name</dt>
  <dd>Logic for sending a patch name update to the synth.</dd>
</dl>

rule::multiPatch

Used with MultiPatchTrusses that can have individual parameter changes sent to the synth (as opposed to some synths that only accept full patch dumps.)

<dl>
  <dt>throttle</dt>
  <dd>Minimum time in milliseconds that Patch Base should wait between sending MIDI data to the synth.</dd>
  <dt>param</dt>
  <dd>The logic for sending individual parameter changes to the synth.</dd>
  <dt>patch</dt>
  <dd>The logic for sending entire patch dumps to the synth. Used when loading a new patch, and also when changes to multiple parameters occur very quickly.</dd>
  <dt>name</dt>
  <dd>Logic for sending a patch name update to the synth.</dd>
</dl>

rule::singleBank

], {
  try .single(throttle: $0.xq("throttle"), .bank($0.x("bank")))
}),

rule::compactSingleBank

  // assume a bank truss has been passed, and make a wholeBank out of it.
  let truss: SingleBankTruss = try $0.x()
  let fn = truss.core.createFileData
  let waitInterval: Int = try $0.xq("waitInterval") ?? 10
  return .single(throttle: nil, .wholeBank(.init({ editor, bodyData in
    try fn.call(bodyData, editor).map { ($0, waitInterval) }
  })))
}),

rule::compactMultiBank

  // assume a bank truss has been passed, and make a wholeBank out of it.
  let truss: MultiBankTruss = try $0.x()
  let fn = truss.core.createFileData
  let waitInterval: Int = try $0.xq("waitInterval") ?? 10
  return .multi(throttle: nil, .wholeBank(.init({ editor, bodyData in
    try fn.call(bodyData, editor).map { ($0, waitInterval) }
  })))
}),