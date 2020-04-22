//
//  GuideCell.swift
//  DeveloperChallengeAppleTVApp
//
//  Created by Advantiss on 4/16/19.
//

import UIKit

class GuideCell: UICollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    internal override func awakeFromNib() {
        let backgroundView = UIView()
        backgroundView.layer.shadowColor = UIColor(white: 0, alpha: 0.2).cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 10)
        backgroundView.layer.shadowRadius = 10
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.cornerRadius = 0
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 1.0
        self.backgroundView = backgroundView
        
        self.lblTitle.textColor = UIColor.gray
    }
    
    var isAiring: Bool = false{
        didSet {
            self.lblTitle.textColor = self.isAiring ? UIColor.white : UIColor.gray
            self.backgroundView?.backgroundColor = self.isAiring ? Const.kEPGAiringColor : UIColor.black
        }
    }
    
    //MARK: Focus
    internal override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        let focused = context.nextFocusedView == self
        focused ? addGestureRecognizer(self.panGesture) : removeGestureRecognizer(self.panGesture)
        
        coordinator.addCoordinatedAnimations({
            self.transform = focused ? self.focusedTransform : CGAffineTransform.identity
            
            self.lblTitle.textColor = focused ? UIColor.white : (self.isAiring ? UIColor.white: UIColor.gray)
            self.lblTitle.transform = CGAffineTransform.identity
            
//            UIColor(red: 69/255.0, green: 90/255.0, blue: 209/255.0, alpha: 1.0)
            self.backgroundView?.backgroundColor = focused ? Const.kEPGHighlightColor : (self.isAiring ? Const.kEPGAiringColor : UIColor.black)
        }, completion: nil)
    }
    
    var focusedTransform: CGAffineTransform {
        let ratio = min(1, (self.frame.size.height + 20) / self.frame.size.height, (self.frame.size.width + 60) / self.frame.size.width)
        return CGAffineTransform(scaleX: ratio, y: ratio)
    }
    
    //MARK: Parallax Effect
    
    var initialPanPosition: CGPoint?
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(GuideCell.panGesture(_:)))
        pan.cancelsTouchesInView = false
        return pan
    }()
    
    @objc func panGesture(_ pan: UIPanGestureRecognizer) {        
        switch pan.state {
        case .began:
            initialPanPosition = pan.location(in: contentView)
        case .changed:
            if let initialPanPosition = self.initialPanPosition {
                let currentPosition = pan.location(in: self.contentView)
                let offset = CGPoint(x: currentPosition.x - initialPanPosition.x, y: currentPosition.y - initialPanPosition.y)
                let coefficient = self.parallaxCoefficient
                
                self.transform = self.focusedTransform.concatenating(CGAffineTransform(translationX: offset.x * coefficient.x, y: offset.y * parallaxCoefficient.y))
                self.lblTitle.transform = CGAffineTransform(translationX: offset.x * -0.5 * coefficient.x, y: offset.y * -0.5 * coefficient.y)
            }
        default:
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {
                self.transform = self.focusedTransform
                self.lblTitle.transform = CGAffineTransform.identity
            },
                           completion: nil)
        }
    }
    
    var parallaxCoefficient: CGPoint {
        return CGPoint(x: min(0.11, 1 / frame.size.width * 16), y: min(0.11, 1 / frame.size.height * 16))
    }
}
