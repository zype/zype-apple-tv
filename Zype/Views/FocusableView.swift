//
//  FocusableView.swift
//  HooplaKidz
//
//  Created by Eugene Lizhnyk on 11/20/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

@IBDesignable
class FocusableView: UIView, UIGestureRecognizerDelegate {
  
  static let scaleSize: CGFloat = 15.0
  
  private var contentView: UIView!
  
  var onSelected: (()->())?
  @IBInspectable var usesTransforms: Bool = true

  override func canBecomeFocused() -> Bool {
    return true
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.clipsToBounds = false
    
    self.contentView = UIView(frame: self.bounds)
    self.contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    self.contentView.layer.cornerRadius = 10
    self.contentView.layer.shadowOffset = CGSizeMake(0, 15)
    self.contentView.layer.shadowRadius = 10
    self.contentView.layer.shadowPath = UIBezierPath(rect: self.contentView.bounds).CGPath
    for view in self.subviews {
      self.contentView.addSubview(view)
    }
    self.addSubview(self.contentView)
  }
  
  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    if(!self.focused) {
      self.contentView.layer.shadowOpacity = 0
    }
    coordinator.addCoordinatedAnimations({ [unowned self] in
      if(self.focused){
        self.contentView.layer.zPosition = 999
        self.contentView.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.resizeContent(false)
      } else {
        self.contentView.layer.zPosition = 0
        self.contentView.layer.backgroundColor = UIColor.clearColor().CGColor
        self.resizeContent(true)
      }
    }, completion: {
      if(self.focused) {
        self.contentView.layer.shadowOpacity = 0.2
      }
    })
  }
  
  func resizeContent(toIdentity: Bool) {
    if(toIdentity) {
      if(self.usesTransforms) {
        self.contentView.transform = CGAffineTransformIdentity
      } else {
        self.contentView.frame = self.bounds
      }
    } else {
      if(self.usesTransforms) {
        let scaleFactor = 1.0 + FocusableView.scaleSize / max(self.width, self.height)
        self.contentView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
      } else {
        let maxDimension = max(self.width, self.height)
        let scalingX = FocusableView.scaleSize * (self.width / maxDimension)
        let scalingY = FocusableView.scaleSize * (self.height / maxDimension)
        let resultRect = CGRectMake(
          -scalingX / 2.0,
          -scalingY / 2.0,
          self.width + scalingX,
          self.height + scalingY)
        self.contentView.frame = resultRect.integral
      }
    }
  }
  
  func pressAnimation(isDown: Bool, completion: (()->())? = nil) {
    UIView.animateWithDuration(0.3, animations: {
      self.resizeContent(isDown)
    }, completion: { _ in
      if let _ = completion {
        completion!()
      }
    })
  }
  
  override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    for item in presses {
      if item.type == .Select {
        self.pressAnimation(true)
      }
    }
  }
  
  override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    for item in presses {
      if item.type == .Select {
        self.pressAnimation(false, completion: self.onSelected)
      }
    }
  }
  
  override func pressesChanged(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
  }
  
  override func pressesCancelled(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    for item in presses {
      if item.type == .Select {
        self.pressAnimation(false)
      }
    }
  }
  
//  var startTouchPosition: CGPoint!
//  
//  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    let touch = touches.first
//    self.startTouchPosition = touch!.locationInView(self)
//  }
//  
//  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    let touch = touches.first
//    let location = touch!.locationInView(self)
//    let dx = location.x - self.startTouchPosition.x
//    let dy = location.y - self.startTouchPosition.y
//    self.transform = CGAffineTransformConcat(FocusableView.standartTransform, CGAffineTransformMakeTranslation(dx/40, dy/40))
//  }
//  
//  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    self.transform = self.focused ? FocusableView.standartTransform : CGAffineTransformIdentity
//  }
//  
//  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//    self.touchesEnded(touches ?? Set<UITouch>(), withEvent: event)
//  }
//  
//  override func canBecomeFirstResponder() -> Bool {
//    return true
//  }
//
}
