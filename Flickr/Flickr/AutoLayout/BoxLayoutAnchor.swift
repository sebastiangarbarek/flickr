//
//  BoxLayoutAnchor.swift
//  SwiftKit
//
//  Created by Sebastian Garbarek on 17/11/18.
//  Copyright © 2018 Sebastian Garbarek. All rights reserved.
//

import UIKit

extension AxisAnchorable {
    
    public var boxAnchor: BoxLayoutAnchor {
        return BoxLayoutAnchor(topAnchor: topAnchor, bottomAnchor: bottomAnchor, leadingAnchor: leadingAnchor, trailingAnchor: trailingAnchor)
    }
    
}

public struct BoxLayoutAnchor {
    
    public var topAnchor: NSLayoutYAxisAnchor
    public var bottomAnchor: NSLayoutYAxisAnchor
    public var leadingAnchor: NSLayoutXAxisAnchor
    public var trailingAnchor: NSLayoutXAxisAnchor
    
    public struct EdgeAnchor: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let top = EdgeAnchor(rawValue: 1 << 0)
        public static let bottom = EdgeAnchor(rawValue: 1 << 1)
        public static let leading = EdgeAnchor(rawValue: 1 << 2)
        public static let trailing = EdgeAnchor(rawValue: 1 << 3)
        
        public static let all: EdgeAnchor = [.top, .bottom, .leading, .trailing]
        public static let allExceptTop = EdgeAnchor.all.subtracting(.top)
        public static let allExceptBottom = EdgeAnchor.all.subtracting(.bottom)
        public static let allExceptTrailing = EdgeAnchor.all.subtracting(.trailing)
        public static let allExceptLeading = EdgeAnchor.all.subtracting(.leading)
    }
    
    public func constraints(equalTo anchor: BoxLayoutAnchor,
                            edgeAnchors: EdgeAnchor = .all,
                            insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        var result: [NSLayoutConstraint] = []
        
        if edgeAnchors.contains(.top) {
            result.append(topAnchor.constraint(equalTo: anchor.topAnchor, constant: insets.top))
        }
        
        if edgeAnchors.contains(.bottom) {
            result.append(bottomAnchor.constraint(equalTo: anchor.bottomAnchor, constant: -insets.bottom))
        }
        
        if edgeAnchors.contains(.leading) {
            result.append(leadingAnchor.constraint(equalTo: anchor.leadingAnchor, constant: insets.left))
        }
        
        if edgeAnchors.contains(.trailing) {
            result.append(trailingAnchor.constraint(equalTo: anchor.trailingAnchor, constant: -insets.right))
        }
        
        return result
    }
    
}
