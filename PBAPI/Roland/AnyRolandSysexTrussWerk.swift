
public protocol AnyRolandSysexTrussWerk {
//  var anyTruss: any SysexTruss { get }
  var start: RolandAddress { get }
  var size: RolandAddress { get }
//  var werk: RolandSysexTrussWerk { get }

//  func anySysexData(_ bodyData: SysexBodyData, deviceId: UInt8, address: RolandAddress) throws -> [[UInt8]]
}

public extension AnyRolandSysexTrussWerk {
  
  func bodyDataCheck<BodyData>(_ bodyData: SysexBodyData, bodyDataType: BodyData.Type) throws -> BodyData {
    guard let bd = bodyData.data() as? BodyData else {
      throw SysexTrussError.incorrectSysexType(msg: "Wrong bodyData type passed. Expected \(BodyData.self) but received \(type(of: bodyData.data()))")
    }
    return bd
  }
  
}
