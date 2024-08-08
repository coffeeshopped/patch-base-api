
public protocol AnySynthEditor {

  func map(fromPath path: SynthPath) -> SynthPath?
  func patch(forPath path: SynthPath) -> AnySysexPatch?

}
