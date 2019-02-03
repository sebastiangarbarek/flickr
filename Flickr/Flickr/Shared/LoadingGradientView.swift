//
//  LoadingGradientView.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(red256: UInt8, green256: UInt8, blue256: UInt8, alpha256: UInt8) {
        self.init(red: CGFloat(red256) / 255.0, green: CGFloat(green256) / 255.0, blue: CGFloat(blue256) / 255.0, alpha: CGFloat(alpha256) / 255.0)
    }

    convenience init(ARGB: UInt32) {
        let maxColorValue: UInt32 = 0xff
        let alpha: UInt32 = (ARGB >> 24) & maxColorValue
        let red: UInt32 = (ARGB >> 16) & maxColorValue
        let green: UInt32 = (ARGB >> 8) & maxColorValue
        let blue: UInt32 = ARGB & maxColorValue
        self.init(red256: UInt8(red), green256: UInt8(green), blue256: UInt8(blue), alpha256: UInt8(alpha))
    }

    convenience init(RGB: UInt32) {
        let ARGB = RGB | 0xff000000
        self.init(ARGB: ARGB)
    }

}

class LoadingGradientView: UIView {

    // MARK: - Constants

    private enum Style {
        static let lighterGray: UIColor = UIColor(RGB: 0xE9E9E9)
    }

    // MARK: - Views

    private var colors: [CGColor] = [Style.lighterGray.cgColor, UIColor.white.withAlphaComponent(0.0).cgColor]

    private lazy var gradientLayer: CAGradientLayer = {
        let result = CAGradientLayer()
        result.colors = colors
        let direction: (x: CGPoint, y: CGPoint) = (x: CGPoint(x: 1, y: 0.5), y: CGPoint(x: 0, y: 0.5))
        result.startPoint = direction.x
        result.endPoint = direction.y
        return result
    }()

    private lazy var gradientAnimation: CABasicAnimation = {
        let result: CABasicAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        result.fromValue = colors
        var colorsReversed = colors
        colorsReversed.reverse()
        result.toValue = colorsReversed
        return result
    }()

    private lazy var animationGroup: CAAnimationGroup = {
        let result: CAAnimationGroup = CAAnimationGroup()
        result.duration = 0.5
        result.repeatCount = .infinity
        result.autoreverses = true
        result.timingFunction = CAMediaTimingFunction(name: .easeOut)
        result.animations = [gradientAnimation]
        result.isRemovedOnCompletion = false
        return result
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false

        gradientLayer.add(animationGroup, forKey: "animationGroup")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
