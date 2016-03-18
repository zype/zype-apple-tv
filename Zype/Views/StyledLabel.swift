//
//  StyledLabel.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 11/3/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

enum LabelStyle: Int {
  case Default = 0
  case ShowCell = 1
  case HeaderCell = 2
  case SubButton = 3
  case MainHeader = 4
  case SubHeader = 5
  case ScreenHeader = 6
  case MainInfo = 7
  case ModalInfo = 8
}

@IBDesignable
class StyledLabel: UILabel {
  
  static let kBaseColor = UIColor(colorLiteralRed: 98/255, green: 93/255, blue: 104/255, alpha: 1)
  static let kFocusedColor = UIColor.whiteColor()
  
  @IBInspectable var style: Int = LabelStyle.Default.rawValue {
    didSet {
      if let computedFont = StyledLabel.fontForStyle(LabelStyle(rawValue: self.style)!) {
        self.font = computedFont
      }
       
      // custom colors
      if let computedColor = StyledLabel.textColorForStyle(LabelStyle(rawValue: self.style)!) {
        self.textColor = computedColor
      }
    }
  }
  
  @IBInspectable var shouldFade: Bool = false {
    didSet {
      if(self.shouldFade) {
        self.lineBreakMode = .ByClipping
        self.maskView = GradientMaskView(frame: self.bounds, insets: UIEdgeInsetsMake(0, 0, 0, 15.0))
      } else {
        self.maskView = nil
      }
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.maskView?.frame = self.bounds
  }
  
  static func fontForStyle(style: LabelStyle) -> UIFont? {
    var font: UIFont? = nil
    switch style {
    case .ShowCell:
      font = UIFont.systemFontOfSize(24)
      break
    case .HeaderCell:
      font = UIFont.boldSystemFontOfSize(38)
      break
    case .SubButton:
      font = UIFont.systemFontOfSize(24)
      break
    case .MainHeader:
      font = UIFont.systemFontOfSize(70, weight: UIFontWeightSemibold)
      break
    case .SubHeader:
      font = UIFont.systemFontOfSize(38)
      break
    case .ScreenHeader:
      font = UIFont.boldSystemFontOfSize(45)
    case .MainInfo:
      font = UIFont.boldSystemFontOfSize(36)
      break
    case .ModalInfo:
      font = UIFont.boldSystemFontOfSize(30)
      break
    default:
      font = UIFont.systemFontOfSize(32)
      break
    }
    return font
  }
    
    static func textColorForStyle(style: LabelStyle) -> UIColor? {
        var color: UIColor? = StyledLabel.kBaseColor
        switch style {
        case .ShowCell:
            color = StyledLabel.kBaseColor
            break
        case .HeaderCell:
            color = StyledLabel.kBaseColor
            break
        case .SubButton:
            color = StyledLabel.kBaseColor
            break
        case .MainHeader:
            color = StyledLabel.kBaseColor
            break
        case .SubHeader:
            color = StyledLabel.kBaseColor
            break
        case .ScreenHeader:
            color = StyledLabel.kBaseColor
        case .MainInfo:
            color = StyledLabel.kBaseColor
            break
        case .ModalInfo:
            color = StyledLabel.kBaseColor
            break
        default:
            color = StyledLabel.kBaseColor
            break
        }
        return color
    }
  
}
