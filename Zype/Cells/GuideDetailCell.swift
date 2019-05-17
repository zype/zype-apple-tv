//
//  GuideDetailCell.swift
//  DeveloperChallengeAppleTVApp
//
//  Created by Advantiss on 4/24/19.
//

import UIKit

class GuideDetailCell: UICollectionViewCell {
 
    internal override func awakeFromNib() {
        let backgroundView = UIView()
        backgroundView.layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)
        backgroundView.layer.shadowRadius = 10
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.cornerRadius = 0
        backgroundView.backgroundColor = Const.kEPGHighlightColor
        backgroundView.alpha = 1.0
        self.backgroundView = backgroundView
    }
    
}
