//
//  URLImage.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/12/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class URLImageView: UIImageView {
  
  static var cache = NSCache()
  static let kAnimationKey = "URLImageViewAnimationKey"
  static let kCornerRadius: CGFloat = 6.0
  
  var downloadTask: NSURLSessionDataTask!
  var thumbnail: UIImage!
  var url: NSURL!
  var isBlurred: Bool = false
  var roundedCorners: UIRectCorner!
  var shouldAnimate: Bool = false
  private  var lastImage: UIImage?
  
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
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        transition.type = kCATransitionFade;
        self.layer.addAnimation(transition, forKey:URLImageView.kAnimationKey)
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if(self.roundedCorners != nil && self.image != nil) {
    if(self.roundedCorners != nil && self.image != nil && !CGSizeEqualToSize(self.frame.size, self.image!.size)) {
      self.configWithURL(self.url)
    }
    }
  }
  
  func roundedCornerImage(sourceImage: UIImage) -> UIImage? {
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
    var thumbnailPoint = CGPointZero
    if (CGSizeEqualToSize(imageSize, targetSize) == false) {
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
    UIBezierPath(roundedRect: CGRect(origin: CGPointZero, size: targetSize), byRoundingCorners: self.roundedCorners, cornerRadii: CGSize(width: URLImageView.kCornerRadius, height: URLImageView.kCornerRadius)).addClip()
    
    var thumbnailRect = CGRectZero
    thumbnailRect.origin = thumbnailPoint
    thumbnailRect.size.width  = scaledWidth
    thumbnailRect.size.height = scaledHeight
    sourceImage.drawInRect(thumbnailRect)
    newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
  
  
  func blurredImage(inputImage: UIImage) -> UIImage{
    let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
    gaussianBlurFilter.setDefaults()
    let inputImage = CIImage(CGImage: inputImage.CGImage!);
    gaussianBlurFilter.setValue(inputImage, forKey:kCIInputImageKey);
    gaussianBlurFilter.setValue(10, forKey:kCIInputRadiusKey);
    let outputImage = gaussianBlurFilter.outputImage
    let context = CIContext(options:nil)
    let cgimg = context.createCGImage(outputImage!, fromRect: inputImage.extent)
    let image = UIImage(CGImage: cgimg!)
    return image
  }
  
  func configWithURL(url: NSURL?) {
    self.url = url
    
    if(self.downloadTask != nil){
      self.downloadTask.cancel()
      self.downloadTask = nil
    }
    
    if(url == nil){
      return
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
      let data: NSData? = URLImageView.cache.objectForKey(url!) as? NSData
      if let goodData = data {
        let image = UIImage(data: goodData)
        dispatch_async(dispatch_get_main_queue(), {() in
          self.image = image
        })
        return
      } else {
        dispatch_async(dispatch_get_main_queue(), {() in
          self.image = nil
        })
      }
      
      self.downloadTask = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        if (error != nil) {
          self.url = nil
          return
        }
        
        if(data != nil) {
          let image = UIImage(data: data!)
          URLImageView.cache.setObject(data!, forKey: url!)
          dispatch_async(dispatch_get_main_queue(), {() in
            self.image = image
            self.downloadTask = nil
          })
        }
      })
      self.downloadTask.resume()
    })
    
  }
  
}
