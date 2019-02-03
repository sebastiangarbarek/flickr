//
//  SizeLayoutAnchor.swift
//  SwiftKit
//
//  Created by Sebastian Garbarek on 17/11/18.
//  Copyright © 2018 Sebastian Garbarek. All rights reserved.
//

import UIKit

public protocol DimensionAnchorable {
    
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    
}

public extension DimensionAnchorable {
    
    public var sizeAnchor: SizeLayoutAnchor {
        return SizeLayoutAnchor(widthAnchor: widthAnchor, heightAnchor: heightAnchor)
    }
    
}

extension UIView: DimensionAnchorable { }
extension UILayoutGuide: DimensionAnchorable { }

public struct SizeLayoutAnchor {

    public var widthAnchor: NSLayoutDimension
    public var heightAnchor: NSLayoutDimension
    
    public func constraints(equalTo size: CGSize) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
    }
    
    public func constraints(greaterThanOrEqualToConstant size: CGSize) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(greaterThanOrEqualToConstant: size.width),
            heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
        ]
    }
    
    public func constraints(equalTo anchor: SizeLayoutAnchor, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(equalTo: anchor.widthAnchor, multiplier: multiplier, constant: constant),
            heightAnchor.constraint(equalTo: anchor.heightAnchor, multiplier: multiplier, constant: constant)
        ]
    }
    
    public func constraints(greaterThanOrEqualTo anchor: SizeLayoutAnchor, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(greaterThanOrEqualTo: anchor.widthAnchor, multiplier: multiplier, constant: constant),
            heightAnchor.constraint(greaterThanOrEqualTo: anchor.heightAnchor, multiplier: multiplier, constant: constant)
        ]
    }
    
    public func constraints(lessThanOrEqualTo anchor: SizeLayoutAnchor, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        return [
            widthAnchor.constraint(lessThanOrEqualTo: anchor.widthAnchor, multiplier: multiplier, constant: constant),
            heightAnchor.constraint(lessThanOrEqualTo: anchor.heightAnchor, multiplier: multiplier, constant: constant)
        ]
    }
    
}
