//
//  PhotoSearchAnimatedTransitioning.swift
//  Flickr
//
//  Created by Sebastian Garbarek on 3/02/19.
//  Copyright © 2019 Sebastian Garbarek. All rights reserved.
//

import UIKit

class PhotoSearchAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    private let operation: UINavigationController.Operation

    init(_ operation: UINavigationController.Operation) {
        self.operation = operation

        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
            let toViewController = transitionContext.viewController(forKey: .to) else {
                return
        }

        if operation == .push {
            let containerView = transitionContext.containerView
            containerView.addSubview(toViewController.view)
            containerView.sendSubviewToBack(toViewController.view)

            let fromViewController = fromViewController as? HomeViewController
            let toViewController = toViewController as? PhotoSearchViewController

            fromViewController?.searchTextField.animate(true)
            toViewController?.searchTextField.animate(true)

            fromViewController?.collectionView.alpha = 1.0
            toViewController?.collectionView.alpha = 0.0

            UIView.animate(withDuration: transitionDuration(using: transitionContext) / 2.0, animations: {
                fromViewController?.collectionView.alpha = 0.0
            }, completion: { _ in
                toViewController?.searchTextField.becomeFirstResponder()

                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) / 2.0, animations: {
                    toViewController?.collectionView.alpha = 1.0
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            })
        } else {
            let containerView = transitionContext.containerView
            containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)

            let toViewController = toViewController as? HomeViewController
            let fromViewController = fromViewController as? PhotoSearchViewController

            toViewController?.searchTextField.animate(false)
            fromViewController?.searchTextField.animate(false)

            toViewController?.collectionView.alpha = 0.0
            fromViewController?.collectionView.alpha = 1.0

            UIView.animate(withDuration: transitionDuration(using: transitionContext) / 2.0, animations: {
                fromViewController?.collectionView.alpha = 0.0
            }, completion: { _ in
                fromViewController?.view.removeFromSuperview()

                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) / 2.0, animations: {
                    toViewController?.collectionView.alpha = 1.0
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            })
        }
    }

}
