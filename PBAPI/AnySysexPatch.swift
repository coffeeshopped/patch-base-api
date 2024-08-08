
public protocol AnySysexPatch : AnySysexible {
  var patchTruss: any PatchTruss { get }
  
  subscript(path: SynthPath) -> Int? { get set }

  func values(_ paths: [SynthPath]) -> SynthPathInts
  func allValues() -> SynthPathInts
  
  mutating func randomize()

  func name(forPath: SynthPath) -> String?
  mutating func set(name: String, forPath: SynthPath)
  func allNames() -> [SynthPath:String]
}
