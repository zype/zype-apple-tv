//
//  PagerCell.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/21/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class PagerCell: UICollectionViewCell {
  
  static let kVerticalShiftOnFocus: CGFloat = 5.0
  
  @IBOutlet weak var imageView: URLImageView!
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.imageView.roundedCorners = [.BottomLeft, .BottomRight]
    self.imageView.thumbnail = UIImage(named: "slider_thumbnail")
  }
  
  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    coordinator.addCoordinatedAnimations({ [unowned self] in
      if(self.focused){
        self.layer.zPosition = 999
        self.imageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, PagerCell.kVerticalShiftOnFocus)
      } else {
        self.layer.zPosition = 0
        self.imageView.transform = CGAffineTransformIdentity
      }
      }, completion: nil)
  }
  
  func configWithURL(url: NSURL?){
    self.imageView.configWithURL(url)
  }
  
  func configWithImageName(name: String){
    self.imageView.image = UIImage(named: name)
  }
  
}
