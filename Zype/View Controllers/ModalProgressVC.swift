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
    self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
    self.label.text = self.text
    self.blurView.layer.cornerRadius = 20.0
    
    let tapRecognizer = UITapGestureRecognizer(target:self, action:#selector(ModalProgressVC.stub))
    tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
    @objc func stub(){}
}
