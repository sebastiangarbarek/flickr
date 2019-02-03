//
//  PositionLayoutAnchor.swift
//  SwiftKit
//
//  Created by Sebastian Garbarek on 17/11/18.
//  Copyright © 2018 Sebastian Garbarek. All rights reserved.
//

import UIKit

public protocol AxisAnchorable {
    
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    
}

extension AxisAnchorable {
    
    public var topLeadingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leadingAnchor, yAnchor: topAnchor)
    }
    
    public var bottomLeadingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leadingAnchor, yAnchor: bottomAnchor)
    }
    
    public var centerYLeadingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leadingAnchor, yAnchor: centerYAnchor)
    }
    
    public var topTrailingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: trailingAnchor, yAnchor: topAnchor)
    }
    
    public var bottomTrailingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: trailingAnchor, yAnchor: bottomAnchor)
    }
    
    public var centerYTrailingAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: trailingAnchor, yAnchor: centerYAnchor)
    }
    
    public var topLeftAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leftAnchor, yAnchor: topAnchor)
    }
    
    public var bottomLeftAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leftAnchor, yAnchor: bottomAnchor)
    }

    public var centerYLeftAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: leftAnchor, yAnchor: centerYAnchor)
    }
    
    public var topRightAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: rightAnchor, yAnchor: topAnchor)
    }
    
    public var bottomRightAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: rightAnchor, yAnchor: bottomAnchor)
    }
    
    public var centerYRightAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: rightAnchor, yAnchor: centerYAnchor)
    }
    
    public var topCenterXAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: centerXAnchor, yAnchor: topAnchor)
    }
    
    public var bottomCenterXAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: centerXAnchor, yAnchor: bottomAnchor)
    }
    
    public var centerYCenterXAnchor: PositionLayoutAnchor {
        return PositionLayoutAnchor(xAnchor: centerXAnchor, yAnchor: centerYAnchor)
    }
    
}

extension UIView: AxisAnchorable { }
extension UILayoutGuide: AxisAnchorable { }

public struct PositionLayoutAnchor {
    
    public var xAnchor: NSLayoutXAxisAnchor
    public var yAnchor: NSLayoutYAxisAnchor
    
    public func constraints(equalTo anchor: PositionLayoutAnchor, offset: UIOffset = .zero) -> [NSLayoutConstraint] {
        return [
            xAnchor.constraint(equalTo: anchor.xAnchor, constant: offset.horizontal),
            yAnchor.constraint(equalTo: anchor.yAnchor, constant: offset.vertical)
        ]
    }
    
    public func constraints(greaterThanOrEqualTo anchor: PositionLayoutAnchor, offset: UIOffset = .zero) -> [NSLayoutConstraint] {
        return [
            xAnchor.constraint(greaterThanOrEqualTo: anchor.xAnchor, constant: offset.horizontal),
            yAnchor.constraint(greaterThanOrEqualTo: anchor.yAnchor, constant: offset.vertical)
        ]
    }
    
    public func constraints(lessThanOrEqualTo anchor: PositionLayoutAnchor, offset: UIOffset = .zero) -> [NSLayoutConstraint] {
        return [
            xAnchor.constraint(lessThanOrEqualTo: anchor.xAnchor, constant: offset.horizontal),
            yAnchor.constraint(lessThanOrEqualTo: anchor.yAnchor, constant: offset.vertical)
        ]
    }

}
