
public enum MidiTransform {

  case single(throttle: Int?, _ fn: Fn<SinglePatchTruss>)
  
  case multi(throttle: Int?, _ fn: Fn<MultiPatchTruss>)
  
  case json(throttle: Int?, _ fn: Fn<JSONPatchTruss>)

  public var throttle: Int {
    switch self {
    case .single(let throttle, _),
        .multi(let throttle, _),
        .json(let throttle, _):
      return throttle ?? 30
    }
  }
  
  
  public enum Fn<Truss:PatchTruss> {

    case patch(coalesce: Int = 2, param: Param?, patch: Whole, name: Name?)
    case multiPatch(params: Params, patch: Whole, name: Name?)
    case bank(BankPatch)
    case wholeBank(WholeBank)
            
    /// Transforms bodyData to a series of MidiMessages / send intervals representing an entire patch. editor provided for possible extra data needed
    public struct Whole {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

    /// Transforms bodyData to a series of MidiMessages / send intervals representing a single parameter change. editor provided for possible extra data needed
    public struct Param {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ path: SynthPath, _ parm: Parm?, _ value: Int) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ path: SynthPath, _ parm: Parm?, _ value: Int) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

    /// Transforms bodyData to a series of MidiMessages / send intervals representing multiple parameter changes. editor provided for possible extra data needed.
    public struct Params {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ values: SynthPathTree<Int>) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ values: SynthPathTree<Int>) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

    /// Transforms bodyData to a series of MidiMessages / send intervals representing a patch name change. editor provided for possible extra data needed
    public struct Name {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ path: SynthPath, _ name: String) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ path: SynthPath, _ name: String) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

    /// Transforms bodyData to a series of MidiMessages / send intervals representing a patch within a bank (in memory). editor provided for possible extra data needed
    public struct BankPatch {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ location: Int) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: Truss.BodyData, _ location: Int) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

    public struct WholeBank {
      public let fn: (_ editor: AnySynthEditor, _ bodyData: [Truss.BodyData]) throws -> [(MidiMessage, Int)]?
      
      public init(_ fn: @escaping (_ editor: AnySynthEditor, _ bodyData: [Truss.BodyData]) throws -> [(MidiMessage, Int)]?) {
        self.fn = fn
      }
    }

  }
  
}




/// For editors that should only send a patch
//  static func pushOnlyPatch<T>(throttle: RxTimeInterval = .milliseconds(30),
//                               input: Observable<(PatchChange, T, Bool)>,
//                               patchTransform: @escaping (_ patch: T) -> [Data]?
//  ) -> Observable<[Data]?> {
//
//    return input.throttle(throttle, scheduler:MainScheduler.instance).map { (change, patch, transmit) in
//      guard transmit else { return nil }
//
//      switch change {
//      case .push:
//        return patchTransform(patch)
//      case .nameChange, .replace, .paramsChange, .noop:
//        return nil
//      }
//    }
//  }


//  /// For multi-patch editors that want to send the subpatch only for multiple changes
//  static func multipatchChange(
//    _ editor: SynthEditor,
//    _ path: SynthPath,
//    throttle: Int?,
//    paramCoalesceCount: Int = 2,
//    paramT: @escaping (_ subpatch: SysexPatch, _ subpatchPath: SynthPath, _ paramPath: SynthPath, _ value: Int) -> [Data]?,
//    patchT: Whole,
//    subpatchT: Whole<SinglePatchTruss>,
//    nameT: Name? = nil
//    ) -> Observable<[Data]?> {
//
//      guard let input = editor.patchStateManager(path)?.typedChangesOutput(SysexPatch<MultiPatchTruss>.self) else { return Observable.just(nil) } // TODO: should probably throw Error here.
//
//    return input.throttle(throttle, scheduler:MainScheduler.instance).map { (change, patch, transmit) in
//      guard transmit else { return nil }
//
//      switch change {
//      case .nameChange(let path, let name):
//        return nameT?(patch.bodyData, path, name)
//
//      case .replace(_), .push:
//        return patchT(patch.bodyData)
//      case .paramsChange(let params):
//        var subchanges = [SynthPath:PatchChange]()
//        // go through all the changes
//        params.forEach { (key, value) in
//          // for each change, find what subpatch it belongs to
//          for prefix in patch.subpatches.keys {
//            guard key.starts(with: prefix) else { continue }
//            let newChange: PatchChange = .paramsChange([key.subpath(from: prefix.count) : value])
//            // collect them all
//            subchanges[prefix] = (subchanges[prefix] ?? .paramsChange([:])).updated(withChange: newChange)
//          }
//        }
//
//        // if there are changes across multiple subpatches, send the whole patch!
//        if subchanges.count > 1 {
//          return patchTransform(patch)
//        }
//
//        guard let (subpatchPath, subchange) = subchanges.first,
//          let subpatch = patch.subpatches[subpatchPath],
//          case let .paramsChange(subparams) = subchange else { return nil }
//
//        if subparams.count > changeThreshold {
//          //, if there are multiple changes, send subpatch
//          return subpatchTransform(subpatch, subpatchPath, patch)
//        }
//        else {
//          //  otherwise, send individual changes
//          let data = subparams.compactMap { (paramPath, value) in
//            return paramTransform(subpatch, subpatchPath, paramPath, value)
//            }.joined()
//          return Array(data)
//        }
//
//      case .noop:
//        return nil
//      }
//    }
//  }


//  /// For editors that only push the bank manually (bc they require being in a Load mode)
//  static func pushOnlyBank<T>(throttle: RxTimeInterval = .milliseconds(30),
//                                         input: Observable<(BankChange, T, Bool)>,
//                                         bankTransform: @escaping (_ bank: T) -> [Data]?
//    ) -> Observable<[Data]?> {
//
//    return input.throttle(throttle, scheduler:MainScheduler.instance).map { (change, bank, transmit) in
//      guard transmit else { return nil }
//
//      switch change {
//      case .push:
//        return bankTransform(bank)
//      case .replace, .patchChange, .patchSwap, .nameChange(_):
//        return nil
//      }
//    }
//  }
