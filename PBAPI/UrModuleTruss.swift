
public protocol UrModuleTruss : ModuleProvider {
  var colorGuide: ColorGuide { get }

  var postAddMessage: String? { get }
}

public protocol ModuleProvider {
  var manufacturer: String { get }
  var model: String { get }
  var productId: String { get }
  var postAddMessage: String? { get }
}
