//
//  URLImage.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/12/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import Kingfisher

class URLImageView: UIImageView {
  
  static var cache = NSCache<AnyObject, AnyObject>()
  static let kAnimationKey = "URLImageViewAnimationKey"
  static let kCornerRadius: CGFloat = 6.0
  
  var downloadTask: URLSessionDataTask!
  var thumbnail: UIImage!
  var url: URL!
  var isBlurred: Bool = false
  var roundedCorners: UIRectCorner!
  var shouldAnimate: Bool = false
  fileprivate  var lastImage: UIImage?
  
  override var image: UIImage? {
    didSet {
      let properImage = self.image ?? self.thumbnail
      if(self.lastImage == properImage) {
        return
      }
      
      if(self.isBlurred && properImage != nil){
        self.lastImage = self.blurredImage(properImage!)
      } else if(self.roundedCorners != nil && properImage != nil) {
        self.lastImage = self.roundedCornerImage(properImage!)
      } else {
        self.lastImage = properImage
      }
      self.image = self.lastImage
      
      if(self.shouldAnimate && self.image != nil) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut);
        transition.type = CATransitionType.fade;
        self.layer.add(transition, forKey:URLImageView.kAnimationKey)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if(self.roundedCorners != nil && self.image != nil) {
    if(self.roundedCorners != nil && self.image != nil && !self.frame.size.equalTo(self.image!.size)) {
      self.configWithURL(self.url, nil)
    }
    }
  }
  
  func roundedCornerImage(_ sourceImage: UIImage) -> UIImage? {
    let targetSize = self.frame.size
    var newImage: UIImage? = nil
    let imageSize = sourceImage.size
    let width = imageSize.width
    let height = imageSize.height
    let targetWidth = targetSize.width
    let targetHeight = targetSize.height
    var scaleFactor: CGFloat = 0.0
    var scaledWidth = targetWidth
    var scaledHeight = targetHeight
    var thumbnailPoint = CGPoint.zero
    if (imageSize.equalTo(targetSize) == false) {
      let widthFactor = targetWidth / width
      let heightFactor = targetHeight / height
      if (widthFactor > heightFactor) {
        scaleFactor = widthFactor
      }
      else {
        scaleFactor = heightFactor
      }
      scaledWidth  = width * scaleFactor
      scaledHeight = height * scaleFactor
      if (widthFactor > heightFactor) {
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
      } else if (widthFactor > heightFactor) {
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
      }
    }
    UIGraphicsBeginImageContext(targetSize)
    UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: targetSize), byRoundingCorners: self.roundedCorners, cornerRadii: CGSize(width: URLImageView.kCornerRadius, height: URLImageView.kCornerRadius)).addClip()
    
    var thumbnailRect = CGRect.zero
    thumbnailRect.origin = thumbnailPoint
    thumbnailRect.size.width  = scaledWidth
    thumbnailRect.size.height = scaledHeight
    sourceImage.draw(in: thumbnailRect)
    newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
  
  
  func blurredImage(_ inputImage: UIImage) -> UIImage{
    let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
    gaussianBlurFilter.setDefaults()
    let inputImage = CIImage(cgImage: inputImage.cgImage!);
    gaussianBlurFilter.setValue(inputImage, forKey:kCIInputImageKey);
    gaussianBlurFilter.setValue(10, forKey:kCIInputRadiusKey);
    let outputImage = gaussianBlurFilter.outputImage
    let context = CIContext(options:nil)
    let cgimg = context.createCGImage(outputImage!, from: inputImage.extent)
    let image = UIImage(cgImage: cgimg!)
    return image
  }
  
    func configWithURL(_ url: URL?,_ thumbnail: UIImage?) {
        self.url = url
        
        if(url == nil){
            return
        }
        
        if (thumbnail == nil){
            self.kf.setImage(with: url)
        } else {
            self.kf.setImage(with: url, placeholder:thumbnail)
        }
    }
  
}
