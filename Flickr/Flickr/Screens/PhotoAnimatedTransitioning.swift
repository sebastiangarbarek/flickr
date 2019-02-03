//
//  PhotoAnimatedTransitioning.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

class PhotoAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    private let operation: UINavigationController.Operation

    init(_ operation: UINavigationController.Operation) {
        self.operation = operation

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }

        if operation == .push {
            let containerView = transitionContext.containerView
            containerView.addSubview(toViewController.view)

            let toViewController = toViewController as? PhotoViewController

            toViewController?.view.alpha = 0.0

            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toViewController?.view.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromViewController = fromViewController as? PhotoViewController

            fromViewController?.view.alpha = 1.0

            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromViewController?.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }

}
