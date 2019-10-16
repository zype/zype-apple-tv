//
//  TransparentFocusableView.swift
//  DeveloperChallengeAppleTVApp
//
//  Created by Advantiss on 10/16/19.
//  Copyright © 2019 Eugene Lizhnyk. All rights reserved.
//

import UIKit

class TransparentFocusableView: UIView {

    override var canBecomeFocused : Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
