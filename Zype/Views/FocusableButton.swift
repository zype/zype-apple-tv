//
//  FocusableButton.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/26/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class FocusableButton: UIButton {

  weak var label: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    if(self.label != nil) {
      self.label.textColor = self.isFocused ? StyledLabel.kFocusedColor : StyledLabel.kBaseColor
      self.label.shadowColor = !self.isFocused ? StyledLabel.kFocusedColor : StyledLabel.kBaseColor
    }
//    coordinator.addCoordinatedAnimations({ [unowned self] in
//      if(self.focused){
//        self.transform = CGAffineTransformMakeScale(1.2, 1.2)
//      } else {
//        self.transform = CGAffineTransformIdentity
//      }
//      }, completion: nil)
  }

}
