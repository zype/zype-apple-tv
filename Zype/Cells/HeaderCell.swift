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
  
  var style: CollectionSectionHeaderStyle = .regular {
    didSet {
      switch self.style {
      case .regular:
        self.label.textAlignment = .left
        break
      case .centered:
        self.label.textAlignment = .center
        break
      }
    }
  }
  
}
