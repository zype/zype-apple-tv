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
    self.imageView.roundedCorners = [.bottomLeft, .bottomRight]
    self.imageView.thumbnail = UIImage(named: "slider_thumbnail")
  }
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    coordinator.addCoordinatedAnimations({ [unowned self] in
      if(self.isFocused){
        self.layer.zPosition = 999
        self.imageView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: PagerCell.kVerticalShiftOnFocus)
      } else {
        self.layer.zPosition = 0
        self.imageView.transform = CGAffineTransform.identity
      }
      }, completion: nil)
  }
  
  func configWithURL(_ url: URL?){
    
    self.imageView.configWithURL(url)
  }
  
  func configWithImageName(_ name: String){
    self.imageView.image = UIImage(named: name)
  }
  
}
