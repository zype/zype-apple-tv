//
//  ScrollableTextAlertVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/19/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class ScrollableTextAlertVC: UIViewController {

  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var clipView: UIView!

  var text: String!
  var header: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(integer: UITouchType.Indirect.rawValue)]
    self.textView.userInteractionEnabled = true
    self.textView.selectable = true
    self.clipView.maskView = GradientMaskView(frame: self.textView.bounds, insets: Const.kScrollableTextVCMaskInsets)
  }
  
  override func viewWillAppear(animated: Bool) {
    let text = self.header == nil ? self.text : (self.header + "\n\n\n\n" + self.text)
    let string = NSMutableAttributedString(string: text)
    if(self.header != nil) {
      let range = NSMakeRange(0, self.header.characters.count)
      let headerStyle = NSMutableParagraphStyle()
      headerStyle.alignment = .Center
      string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(38), range: range)
      string.addAttribute(NSParagraphStyleAttributeName, value: headerStyle, range: range)
    }
    string.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(24), range: NSMakeRange(text.characters.count - self.text.characters.count, self.text.characters.count))
    self.textView.attributedText = string
  }
  func configWithText(text: String, header: String? = nil, title: String){
    self.text = title + "\n\n" + text
    self.header = header
  }

}
