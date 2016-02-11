//
//  FlickrPhotoCell.swift
//  FlickrSearch
//
//  Created by Richard Turton on 13/04/2015.
//  Copyright (c) 2015 Richard turton. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: URLImageView!
  @IBOutlet weak var label: UILabel!
  
  var item: CollectionLabeledItem!
  private var observerContext = 0
  
  deinit {
    self.removeItemObservers()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.imageView.thumbnail = UIImage(named: "show_thumbnail")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    coordinator.addCoordinatedAnimations({ [unowned self] in
      if(self.focused) {
        self.label.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.2, 1.2), CGAffineTransformMakeTranslation(0, 20)) ;
        self.label.textColor = StyledLabel.kFocusedColor
      }
      else {
        self.label.transform = CGAffineTransformIdentity
        self.label.textColor = StyledLabel.kBaseColor
      }
    }, completion: nil)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if(context == &self.observerContext) {
      let item = object as! CollectionLabeledItem
      if(keyPath == CollectionLabeledItem.kImageObservableKey) {
        self.imageView.configWithURL(item.imageURL)
      } else if(keyPath == CollectionLabeledItem.kTitleObservableKey) {
        self.label.text = item.title
      }
    } else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
  }
  
  func addItemObservers(){
    if(self.item != nil){
      self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey, options: .New, context: &self.observerContext)
      self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey, options: .New, context: &self.observerContext)
    }
  }
  
  func removeItemObservers(){
    if(self.item != nil){
      self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey)
      self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey)
    }
  }
  
  func configWithItem(item: CollectionLabeledItem){
    self.removeItemObservers()
    self.label.text = item.title
    if(item.imageURL == nil && item.imageName != nil) {
      self.imageView.image = UIImage(named: item.imageName)
    } else {
      self.imageView.configWithURL(item.imageURL)
    }
    self.item = item
    self.addItemObservers()
  }
  
}
