//
//  StyledLabel.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 11/3/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

enum LabelStyle: Int {
  case `default` = 0
  case showCell = 1
  case headerCell = 2
  case subButton = 3
  case mainHeader = 4
  case subHeader = 5
  case screenHeader = 6
  case mainInfo = 7
  case modalInfo = 8
}

@IBDesignable
class StyledLabel: UILabel {
  
//   This base color needs to be changed based on the theme
//   If the theme is dark, keep it white. If the theme is light, make this as black.
    static let kBaseColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
  static let kFocusedColor = UIColor.black
  
  @IBInspectable var style: Int = LabelStyle.default.rawValue {
    didSet {
      if let computedFont = StyledLabel.fontForStyle(LabelStyle(rawValue: self.style)!) {
        self.font = computedFont
        self.textColor = StyledLabel.kBaseColor
      }
    }
  }
  
  @IBInspectable var shouldFade: Bool = false {
    didSet {
      if(self.shouldFade) {
        self.lineBreakMode = .byClipping
        self.mask = GradientMaskView(frame: self.bounds, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15.0))
      } else {
        self.mask = nil
      }
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.mask?.frame = self.bounds
  }
  
  static func fontForStyle(_ style: LabelStyle) -> UIFont? {
    var font: UIFont? = nil
    switch style {
    case .showCell:
      font = UIFont.systemFont(ofSize: 24)
      break
    case .headerCell:
      font = UIFont.boldSystemFont(ofSize: 38)
      break
    case .subButton:
      font = UIFont.systemFont(ofSize: 24)
      break
    case .mainHeader:
      font = UIFont.systemFont(ofSize: 21)
      break
    case .subHeader:
      font = UIFont.systemFont(ofSize: 50)
      break
    case .screenHeader:
      font = UIFont.boldSystemFont(ofSize: 45)
    case .mainInfo:
      font = UIFont.boldSystemFont(ofSize: 36)
      break
    case .modalInfo:
      font = UIFont.boldSystemFont(ofSize: 30)
      break
    default:
      font = UIFont.systemFont(ofSize: 32)
      break
    }
    return font
  }
  
}
