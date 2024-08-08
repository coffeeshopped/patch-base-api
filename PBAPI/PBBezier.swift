
public enum PBBezier {
  
  public enum PathCommand {
    
    case move(to: CGPoint)
    case addLine(to: CGPoint)
    case addCurve(to: CGPoint, controlPoint1: CGPoint? = nil, controlPoint2: CGPoint? = nil)
    case apply(CGAffineTransform)
    case addWeightedCurve(to: CGPoint, weight: CGFloat = 0)
    
  }
  
}
