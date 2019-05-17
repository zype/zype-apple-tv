//
//  GuideDateHeader.swift
//  DeveloperChallengeAppleTVApp
//
//  Created by Advantiss on 4/17/19.
//

import UIKit

class GuideDateHeader: UICollectionReusableView {
    
    var label: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    internal func commonInit() {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.bounds
//        gradientLayer.colors = [UIColor(red: 104/255.0, green: 49/255.0, blue: 239/255.0, alpha: 1.0).cgColor,
//                                UIColor(red: 22/255.0, green: 15/255.0, blue: 92/255.0, alpha: 1.0).cgColor]
//        self.layer.addSublayer(gradientLayer)
        
        self.backgroundColor = UIColor(red: 44/255.0, green: 44/255.0, blue: 44/255.0, alpha: 1.0)
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightMedium)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.label = label
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-|", options: [], metrics: nil, views: ["label": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[label]-0-|", options: [], metrics: nil, views: ["label": label]))
    }
    
}
