
public struct JSONPatchTruss : PatchTruss {
  
  public typealias BodyData = [String:Int]
  public func sysexBodyData(_ data: BodyData) -> SysexBodyData { .json(data) }

  public let core: Core
  public let params: SynthPathParam

  private static let decoder = JSONDecoder()
  private static let encoder = JSONEncoder()

  public init(_ displayId: String, parms: [Parm], initFile: String = "") {
    self.params = parms.params()
    self.core = Core(displayId,
                     initFile: initFile,
                     fileDataCount: 0,
                     createFileData: { b, e in try Self.encoder.encode(b).bytes() },
                     parseBodyData: {
      do {
        return try Self.decoder.decode([String:Int].self, from: Data($0))
      } catch {
        print("Unexpected error: \(error).")
        return [String:Int]()
      }
    },
                     isValidSize: { _ in true },
                     isValidFileData: { _ in true },
                     isCompleteFetch: { _ in true })
  }

  public func getValue(_ bodyData: [String : Int], path: SynthPath) -> Int? {
    bodyData[JsSynthPath.encode(path)]
  }
  
  public func setValue(_ bodyData: inout [String : Int], path: SynthPath, _ value: Int) {
    bodyData[JsSynthPath.encode(path)] = value
  }
  
  public func allValues(_ bodyData: [String : Int]) -> SynthPathInts {
    SynthPathIntsMake(params.keys.dict { [$0 : bodyData[JsSynthPath.encode($0)] ?? 0] })
  }
  
  public func getName(_ bodyData: [String : Int]) -> String? { nil }
  public func setName(_ bodyData: inout [String : Int], _ value: String) { }
  public func getName(_ bodyData: [String : Int], forPath path: SynthPath) -> String? { nil }
  public func setName(_ bodyData: inout [String : Int], forPath path: SynthPath, _ name: String) { }
  public func allNames(_ bodyData: [String : Int]) -> [SynthPath : String] { [:] }
  
  public func parm(_ path: SynthPath) -> Parm? { params[path] }
  public func paramKeys() -> [SynthPath] { Array(params.keys) }

  public func subpaths(_ path: SynthPath) -> [SynthPath]? { [path] }
    
  public func createEmptyBodyData() throws -> BodyData { [:] }
    
  public func randomize() -> SynthPathInts {
    .init(params.dict { [$0.key : $0.value.param().randomize()] })
  }

}
