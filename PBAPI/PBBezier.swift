
public enum PBBezier {
  
  public enum PathCommand {
    
    case move(to: CGPoint)
    case addLine(to: CGPoint)
    case addCurve(to: CGPoint, controlPoint1: CGPoint? = nil, controlPoint2: CGPoint? = nil)
    case apply(CGAffineTransform)
    case addWeightedCurve(to: CGPoint, weight: CGFloat = 0)
    
    public func validate() throws {
      switch self {
      case .move(let to):
        break
      case .addLine(let to):
        if to.x.isNaN || to.y.isNaN {
          throw PBError.error("PBBezier.PathCommand: x and y cannot be NaN: \(to)")
        }
      case .addCurve(let to, let controlPoint1, let controlPoint2):
        break
      case .apply(let t):
        break
      case .addWeightedCurve(let to, let weight):
        break
      }
    }
  }
  
}
