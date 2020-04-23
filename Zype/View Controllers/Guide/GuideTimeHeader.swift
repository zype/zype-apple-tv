//
//  GuideTimeHeader.swift
//
//  Created by Advantiss
//

import UIKit

open class GuideTimeHeader : UICollectionReusableView {
    
    var titleLabel: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: UIFontWeightMedium)
        titleLabel.textColor = UIColor.white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[titleLabel]", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: nil, views: ["titleLabel": titleLabel]))
        
//        let seperator = UIView()
//        seperator.backgroundColor = UIColor.gray
//        seperator.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(seperator)
//
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[seperator]-5-|", options: [], metrics: nil, views: ["seperator": seperator]))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[seperator]-|", options: [], metrics: nil, views: ["seperator": seperator]))
//        seperator.widthAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
}
