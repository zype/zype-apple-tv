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
  fileprivate var observerContext = 0
  
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
  
  override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocus(in: context, with: coordinator)
    coordinator.addCoordinatedAnimations({ [unowned self] in
      if(self.isFocused) {
        self.label.transform = CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(CGAffineTransform(translationX: 0, y: 20)) ;
        self.label.textColor = StyledLabel.kFocusedColor
      }
      else {
        self.label.transform = CGAffineTransform.identity
        self.label.textColor = StyledLabel.kBaseColor
      }
    }, completion: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if(context == &self.observerContext) {
      let item = object as! CollectionLabeledItem
      if(keyPath == CollectionLabeledItem.kImageObservableKey) {
        self.imageView.configWithURL(item.imageURL)
      } else if(keyPath == CollectionLabeledItem.kTitleObservableKey) {
        self.label.text = item.title
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  func addItemObservers(){
    if(self.item != nil){
      self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey, options: .new, context: &self.observerContext)
      self.item.addObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey, options: .new, context: &self.observerContext)
    }
  }
  
  func removeItemObservers(){
    if(self.item != nil){
      self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kImageObservableKey)
      self.item.removeObserver(self, forKeyPath: CollectionLabeledItem.kTitleObservableKey)
    }
  }
  
  func configWithItem(_ item: CollectionLabeledItem){
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
