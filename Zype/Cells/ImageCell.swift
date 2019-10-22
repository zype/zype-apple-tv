//
//  ImageCell.swift
//  AndreySandbox
//
//  Created by Eric Chang on 7/18/17.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: URLImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var lockImage: UIImageView!
    
    var item: CollectionLabeledItem!
    fileprivate var observerContext = 0
    
    deinit {
        self.removeItemObservers()
    }
    
    var lockStyle: CollectionLockStyle = .empty {
        didSet {
            guard Const.kLockIcons else { return }
            switch self.lockStyle {
            case .empty:
                self.lockImage.isHidden = true
            case .locked:
                self.lockImage.image = ZypeUtilities.imageFromResourceBundle("iconLocked.png")
            case .unlocked:
                self.lockImage.image = ZypeUtilities.imageFromResourceBundle("iconUnlocked.png")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.thumbnail = UIImage(named: "show_thumbnail")
        self.imageView.image = self.imageView.thumbnail
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.lockImage.isHidden = false
        self.imageView.image = nil
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations({ [unowned self] in
            if(self.isFocused) {
                self.label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(CGAffineTransform(translationX: 0, y: 20)) ;
                self.label.textColor = UIColor.black
            }
            else {
                self.label.transform = CGAffineTransform.identity
                self.label.textColor = StyledLabel.kBaseColor
            }
            }, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.observerContext {
            let item = object as! CollectionLabeledItem
            if keyPath == CollectionLabeledItem.kImageObservableKey {
                self.imageView.configWithURL(item.imageURL, UIImage(named: "show_thumbnail"))
            }
            else if keyPath == CollectionLabeledItem.kTitleObservableKey {
                self.label.text = item.title
            }
            else if keyPath == CollectionLabeledItem.kLockObservableKey {
                self.lockStyle = item.lockStyle!
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func addItemObservers(){
        if self.item != nil {
            self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey, options: .new, context: &self.observerContext)
            self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey, options: .new, context: &self.observerContext)
            self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kLockObservableKey, options: .new, context: &self.observerContext)
        }
    }
    
    func removeItemObservers(){
        if(self.item != nil){
            self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey)
            self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey)
            self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kLockObservableKey)
        }
    }
    
    func configWithItem(_ item: CollectionLabeledItem, orientation: LayoutOrientation){
        self.removeItemObservers()
        self.label.text = item.title
        
        if (Const.kInlineTitleTextDisplay) {
            self.label.lineBreakMode = .byTruncatingTail
            
            let constraintRect = CGSize(width: Const.kCollectionCellSize.width, height: .greatestFiniteMagnitude)
            let boundingBox = item.title.boundingRect(with: constraintRect,
                                                      options: .usesLineFragmentOrigin,
                                                      attributes: [NSFontAttributeName: self.label.font],
                                                      context: nil)
            let labelHeight = ceil(boundingBox.height)
            var labelFrame = self.label.frame
            if (labelHeight > 46) {
                labelFrame.size.height = 92
            } else {
                labelFrame.size.height = 46
            }
            self.label.frame = labelFrame
        } else {
            var labelFrame = self.label.frame
            labelFrame.size.height = 0
            self.label.frame = labelFrame
        }
        
        if orientation == .poster {
            if item.posterURL == nil && item.imageName != nil {
                self.imageView.image = UIImage(named: item.imageName)
            } else {
                if item.posterURL != nil {
                    self.imageView.configWithURL(item.posterURL, UIImage(named: "show_thumbnail"))
                } else {
                    self.imageView.configWithURL(item.imageURL, UIImage(named: "show_thumbnail"))
                }
            }
        } else {
            if item.imageURL == nil && item.imageName != nil {
                self.imageView.image = UIImage(named: item.imageName)
            }
            else {
                self.imageView.configWithURL(item.imageURL, UIImage(named: "show_thumbnail"))
            }
        }
        
        if item.lockStyle != nil {
            self.lockStyle = item.lockStyle!
        }
        self.item = item
        self.addItemObservers()
    }
    
}
