//
//  FadeNavigationAnimationController.swift
//
//  Created by Eugene Lizhnyk on 11/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class FadeNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  var reverse: Bool = false
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let finalFrameForVC = transitionContext.finalFrame(for: toViewController)
    let containerView = transitionContext.containerView
    
    toViewController.view.frame = finalFrameForVC
    if(!self.reverse) {
      containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
    } else {
      containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
      toViewController.view.transform = CGAffineTransform(scaleX: 2, y: 2)
    }
    toViewController.view.alpha = 0.0
    fromViewController.view.alpha = 1.0
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      if(!self.reverse) {
        fromViewController.view.transform = CGAffineTransform(scaleX: 2, y: 2)
      }
      fromViewController.view.alpha = 0
      toViewController.view.alpha = 1.0
      toViewController.view.transform = CGAffineTransform.identity
      }, completion: { finished in
        transitionContext.completeTransition(true)
        fromViewController.view.alpha = 1.0
        fromViewController.view.transform = CGAffineTransform.identity
    })
  }
  
}
