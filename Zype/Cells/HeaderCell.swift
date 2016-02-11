//
//  HeaderCell.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/30/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class HeaderCell: UICollectionReusableView {
        
  @IBOutlet weak var label: UILabel!
  
  var style: CollectionSectionHeaderStyle = .Regular {
    didSet {
      switch self.style {
      case .Regular:
        self.label.textAlignment = .Left
        break
      case .Centered:
        self.label.textAlignment = .Center
        break
      }
    }
  }
  
}
