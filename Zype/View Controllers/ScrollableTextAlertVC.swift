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
    self.textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue as Int)]
    self.textView.isUserInteractionEnabled = true
    self.textView.isSelectable = true
    self.clipView.mask = GradientMaskView(frame: self.textView.bounds, insets: Const.kScrollableTextVCMaskInsets)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let text = self.header == nil ? self.text : (self.header + "\n\n\n\n" + self.text)
    let string = NSMutableAttributedString(string: text!)
    if(self.header != nil) {
      let range = NSMakeRange(0, self.header.characters.count)
      let headerStyle = NSMutableParagraphStyle()
      headerStyle.alignment = .center
      string.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 38), range: range)
      string.addAttribute(NSParagraphStyleAttributeName, value: headerStyle, range: range)
    }
    string.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 24), range: NSMakeRange((text?.characters.count)! - self.text.characters.count, self.text.characters.count))
    self.textView.attributedText = string
  }
  func configWithText(_ text: String, header: String? = nil, title: String){
    self.text = title + "\n\n" + text
    self.header = header
  }

}
