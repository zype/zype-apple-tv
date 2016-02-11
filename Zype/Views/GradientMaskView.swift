import UIKit

class GradientMaskView: UIView {
  
  var maskInsets: UIEdgeInsets {
    didSet {
      self.updateGradientLayer()
    }
  }
  var gradients = [CAGradientLayer(), CAGradientLayer(), CAGradientLayer(), CAGradientLayer()]
  var visible = CALayer()
  
  private let gradientLayer: CAGradientLayer = {
    let layer = CAGradientLayer()
    layer.colors = [UIColor(white: 0.0, alpha: 0.0).CGColor, UIColor(white: 0.0, alpha: 1.0).CGColor]
    
    return layer
  }()
  
  func prepareGradients() {
    for gradient in self.gradients {
      layer.addSublayer(gradient)
      gradient.colors = [UIColor(white: 0.0, alpha: 0.0).CGColor, UIColor(white: 0.0, alpha: 1.0).CGColor]
    }
    layer.addSublayer(self.visible)
    self.visible.backgroundColor = UIColor.blackColor().CGColor
  }
  
  init(frame: CGRect, insets: UIEdgeInsets) {
    self.maskInsets = insets
    super.init(frame: frame)
    self.prepareGradients()
    self.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.maskInsets = UIEdgeInsetsZero
    self.maskInsets.top = 20
    self.maskInsets.bottom = 20
    super.init(coder: aDecoder)
    self.prepareGradients()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    updateGradientLayer()
  }
  
  private func updateGradientLayer() {
    var gradient: CAGradientLayer
    if(self.maskInsets.top > 0) {
      gradient = self.gradients[0]
      gradient.frame = CGRect(x: 0, y: 0, width: self.width, height: self.maskInsets.top)
    }
    if(self.maskInsets.bottom > 0) {
      gradient = self.gradients[1]
      gradient.frame = CGRect(x: 0, y: self.height - self.maskInsets.bottom, width: self.width, height: self.maskInsets.bottom)
      gradient.startPoint = CGPoint(x: 0, y: 1)
      gradient.endPoint = CGPoint(x: 0, y: 0)
    }
    if(self.maskInsets.left > 0) {
      gradient = self.gradients[2]
      gradient.frame = CGRect(x: 0, y: 0, width: self.maskInsets.left, height: self.height)
      gradient.startPoint = CGPoint(x: 0, y: 0)
      gradient.endPoint = CGPoint(x: 1, y: 0)
    }
    if(self.maskInsets.right > 0) {
      gradient = self.gradients[3]
      gradient.frame = CGRect(x: self.width - self.maskInsets.right, y: 0, width: self.maskInsets.right, height: self.height)
      gradient.startPoint = CGPoint(x: 1, y: 0)
      gradient.endPoint = CGPoint(x: 0, y: 0)
    }
    self.visible.frame = UIEdgeInsetsInsetRect(self.bounds, self.maskInsets)
  }
  
}
