//
//  ModalProgressVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/29/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class ModalProgressVC: UIViewController {

  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var label: UILabel!
  
  var text: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.activityIndicator.transform = CGAffineTransformMakeScale(3, 3)
    self.label.text = self.text
    self.blurView.layer.cornerRadius = 20.0
    
    let tapRecognizer = UITapGestureRecognizer(target:self, action:"stub")
    tapRecognizer.allowedPressTypes = [UIPressType.Menu.rawValue]
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  func stub(){}
}
