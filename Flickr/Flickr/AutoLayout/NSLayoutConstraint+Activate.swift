//
//  NSLayoutConstraint+Activate.swift
//  SwiftKit
//
//  Created by Sebastian Garbarek on 17/11/18.
//  Copyright © 2018 Sebastian Garbarek. All rights reserved.
//

import UIKit

public protocol LayoutConstraintArrayConvertible {
    
    func layoutConstraintArray() -> [NSLayoutConstraint]
    
}

extension NSLayoutConstraint: LayoutConstraintArrayConvertible {
    
    public func layoutConstraintArray() -> [NSLayoutConstraint] {
        return [self]
    }
    
}

extension Array: LayoutConstraintArrayConvertible where Element: NSLayoutConstraint {
    
    public func layoutConstraintArray() -> [NSLayoutConstraint] {
        return self
    }
    
}

extension NSLayoutConstraint {
    
    public static func activate(_ constraints: [LayoutConstraintArrayConvertible]) {
        activate(Array(constraints.map({ $0.layoutConstraintArray() }).joined()))
    }
    
    public static func deactivate(_ constraints: [LayoutConstraintArrayConvertible]) {
        deactivate(Array(constraints.map({ $0.layoutConstraintArray() }).joined()))
    }
    
    public static func activate(priority: UILayoutPriority, _ constraints: [LayoutConstraintArrayConvertible]) {
        let singleTypeArray: [NSLayoutConstraint] = Array(constraints.map({ $0.layoutConstraintArray() }).joined())
        
        for constraint in singleTypeArray {
            constraint.priority = priority
        }
        
        activate(singleTypeArray)
    }
    
}
