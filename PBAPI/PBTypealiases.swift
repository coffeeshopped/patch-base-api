
#if os(macOS)
import AppKit

public typealias PBDataAsset = NSDataAsset
public typealias PBColor = NSColor

#else
import UIKit

public typealias PBDataAsset = NSDataAsset
public typealias PBColor = UIColor

#endif
