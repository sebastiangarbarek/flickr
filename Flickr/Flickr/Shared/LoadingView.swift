//
//  LoadingView.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    // MARK: - Views

    private let circleLayer: CAShapeLayer = {
        let result: CAShapeLayer = CAShapeLayer()
        result.fillColor = UIColor.blue.cgColor
        return result
    }()

    private let scaleAnimation: CABasicAnimation = {
        let result: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        result.fromValue = 0.0
        result.toValue = 1.0
        return result
    }()

    private let alphaAnimation: CABasicAnimation = {
        let result: CABasicAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        result.fromValue = 0.0
        result.toValue = 1.0
        return result
    }()

    private lazy var animationGroup: CAAnimationGroup = {
        let result: CAAnimationGroup = CAAnimationGroup()
        result.duration = 0.5
        result.repeatCount = .infinity
        result.autoreverses = true
        result.timingFunction = CAMediaTimingFunction(name: .easeOut)
        result.animations = [scaleAnimation, alphaAnimation]
        result.isRemovedOnCompletion = false
        return result
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(circleLayer)
        circleLayer.add(animationGroup, forKey: "animationGroup")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circleLayer.frame = bounds
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
