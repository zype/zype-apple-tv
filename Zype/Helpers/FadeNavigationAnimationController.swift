//
//  FadeNavigationAnimationController.swift
//  HooplaKidz
//
//  Created by Eugene Lizhnyk on 11/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class FadeNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  var reverse: Bool = false
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    let finalFrameForVC = transitionContext.finalFrameForViewController(toViewController)
    let containerView = transitionContext.containerView()
    
    toViewController.view.frame = finalFrameForVC
    if(!self.reverse) {
      containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
    } else {
      containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
      toViewController.view.transform = CGAffineTransformMakeScale(2, 2)
    }
    toViewController.view.alpha = 0.0
    fromViewController.view.alpha = 1.0
    
    UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
      if(!self.reverse) {
        fromViewController.view.transform = CGAffineTransformMakeScale(2, 2)
      }
      fromViewController.view.alpha = 0
      toViewController.view.alpha = 1.0
      toViewController.view.transform = CGAffineTransformIdentity
      }, completion: { finished in
        transitionContext.completeTransition(true)
        fromViewController.view.alpha = 1.0
        fromViewController.view.transform = CGAffineTransformIdentity
    })
  }
  
}
