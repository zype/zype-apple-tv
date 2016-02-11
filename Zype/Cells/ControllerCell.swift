//
//  GalleryHeaderCell.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class ControllerCell: UICollectionViewCell {
  var controller: UIViewController!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    if (self.contentView.subviews.count > 0) {
      self.contentView.subviews.first!.removeFromSuperview()
    }
  }
  
  func config(controller: UIViewController) {
    controller.view.origin = CGPointZero
    controller.view.width = self.contentView.width
    controller.view.autoresizingMask = .FlexibleWidth
    self.contentView.addSubview(controller.view)
    self.controller = controller
  }
  
}

