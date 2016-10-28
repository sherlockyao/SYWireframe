//
//  WireframeTransition.swift
//  Example-iOS
//
//  Created by SherlockYao on 10/28/16.
//  Copyright © 2016 SherlockYao. All rights reserved.
//

import Foundation
import SYWireframe

struct WireframeTransition : SYWireframeTransition {
    
    let slideAnimation = SlideTransitionAnimation()
    
    func setupTransition(from soureViewController: UIViewController, to destinationViewController: UIViewController) {
        
        // if source is Home
        if soureViewController is HomeViewController {
            
            // if destination is Seller
            if destinationViewController is SellerViewController {
                destinationViewController.transitioningDelegate = slideAnimation
            }
        }
    }
    
    func setupTransition(for navigationController: UINavigationController) {
    }
}

/// Custom transition animations
class SlideTransitionAnimation : NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let endFrame = transitionContext.finalFrame(for: destinationViewController)
        let beginFrame = CGRect(x: endFrame.size.width, y: endFrame.size.height / 2, width: endFrame.size.width, height: endFrame.size.height)
        
        
        destinationViewController.view.frame = beginFrame
        transitionContext.containerView.addSubview(destinationViewController.view)
        
        UIView.animate(withDuration: 0.4, animations: { 
            destinationViewController.view.frame = endFrame
        }) { (didComplete) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
