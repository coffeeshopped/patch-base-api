
public protocol AnyMultiSysexible : AnySysexible {
  var multiTruss: any MultiSysexTruss { get }
  var bodyData: MultiSysexTrussBodyData { get }

  mutating func setSysexible(_ sysexible: AnySysexible, path: SynthPath) throws
  func getSysexible(path: SynthPath) throws -> AnySysexible?

}
