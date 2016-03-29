//
//  ShwDetailsVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeSDK

class ShowDetailsVC: CollectionContainerVC {
  
  static let kDescriptionTopMargin: CGFloat = 30.0
  static let kSubtitleTopMargin: CGFloat = 20.0

  @IBOutlet weak var posterImage: URLImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  @IBOutlet weak var labelsView: UIView!
  @IBOutlet weak var bottomBarView: UIView!
  @IBOutlet weak var favoritesButton: FocusableButton!
  @IBOutlet weak var subscribeButton: FocusableButton!
  @IBOutlet weak var detailsView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var subscribeLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  @IBOutlet weak var episodesCountLabel: StyledLabel!
  @IBOutlet weak var descriptionView: FocusableView!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  var selectedShow: PlaylistModel!
  var selectedVideo: VideoModel!
  var videos: Array<VideoModel>!
  var focusGuide: UIFocusGuide!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.subscribeLabel.text = localized("ShowDetails.SubscribedButton")
    self.favoriteLabel.text = localized("ShowDetails.Favorite")
    self.descriptionLabel.textColor = StyledLabel.kBaseColor
    self.descriptionView.onSelected = {
      self.onExpandDescription()
    }
    self.subscribeButton.setBackgroundImage(UIImage(named: "Subscribed"), forState: .Normal)
    
    let distance = (self.containerView.top - self.detailsView.bottom) / 2
    
    self.focusGuide = UIFocusGuide()
    self.view.addLayoutGuide(focusGuide)
    self.focusGuide.leftAnchor.constraintEqualToAnchor(self.detailsView.leftAnchor).active = true
    self.focusGuide.bottomAnchor.constraintEqualToAnchor(self.containerView.topAnchor, constant: -distance).active = true
    self.focusGuide.topAnchor.constraintEqualToAnchor(self.detailsView.bottomAnchor).active = true
    self.focusGuide.rightAnchor.constraintEqualToAnchor(self.detailsView.rightAnchor).active = true
    
    let favoritesButtonGuide = UIFocusGuide()
    self.view.addLayoutGuide(favoritesButtonGuide)
    favoritesButtonGuide.leftAnchor.constraintEqualToAnchor(self.detailsView.leftAnchor).active = true
    favoritesButtonGuide.bottomAnchor.constraintEqualToAnchor(self.containerView.topAnchor).active = true
    favoritesButtonGuide.topAnchor.constraintEqualToAnchor(self.detailsView.bottomAnchor, constant: distance).active = true
    favoritesButtonGuide.rightAnchor.constraintEqualToAnchor(self.detailsView.rightAnchor).active = true
    favoritesButtonGuide.preferredFocusedView = self.favoritesButton
    
    self.favoritesButton.label = self.favoriteLabel
    self.subscribeButton.label = self.subscribeLabel
    
    self.posterImage.shouldAnimate = true
    self.titleLabel.text = self.selectedShow.titleString
    self.loadVideos()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let path = self.indexPathForselectedVideo() {
      self.collectionVC.collectionView?.scrollToItemAtIndexPath(path, atScrollPosition: .CenteredHorizontally, animated: false)
    }
  }
  
  override func viewWillLayoutSubviews(){
    super.viewWillLayoutSubviews()
    self.layoutLabels()
  }
  
  override weak var preferredFocusedView: UIView? {
    get {
      if let path = self.indexPathForselectedVideo() {
        return self.collectionVC.collectionView?.cellForItemAtIndexPath(path)
      }
      return super.preferredFocusedView
    }
  }
  
  func indexPathForselectedVideo() -> NSIndexPath? {
    if(self.selectedVideo != nil) {
      return NSIndexPath(forRow: self.videos.indexOf(self.selectedVideo)!, inSection: 0)
    }
    return nil
  }

  func layoutLabels(){
    for label in self.labelsView.subviews {
      if(label.isKindOfClass(UILabel)) {
        label.width = self.labelsView.width
        // label.sizeToFit()
      }
    }
    self.subTitleLabel.top = self.titleLabel.bottom + ShowDetailsVC.kSubtitleTopMargin
    self.descriptionView.height = self.labelsView.height - self.descriptionView.top
  }
  
  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    self.focusGuide.preferredFocusedView = self.preferredFocusedView
  }
  
  override func onItemFocused(item: CollectionLabeledItem, section: CollectionSection?) {
    self.onVideoFocused(item.object as! VideoModel)
  }
  
  override func onItemSelected(item: CollectionLabeledItem, section: CollectionSection?) {
    self.playVideo(item.object as! VideoModel, playlist: section?.allObjects() as? Array<VideoModel>)
  }
  
  func loadVideos(){
    self.selectedShow.getVideos(NSDate.distantPast(), completion: {[unowned self] (videos: Array<VideoModel>?, error: NSError?) -> Void in
      self.videos = videos
      let videosCount = videos?.count ?? 0
      self.episodesCountLabel.text = String(format: localized(videosCount == 1 ? "ShowDetails.Episode" : "ShowDetails.EpisodesCount"), arguments: [videosCount])
      let section = CollectionSection()
      section.items = CollectionContainerVC.videosToCollectionItems(videos)
      self.collectionVC.configWithSection(section)
    })
  }

  func onVideoFocused(video: VideoModel){
    self.selectedVideo = video
    self.posterImage.configWithURL(video.posterURL())
    self.subTitleLabel.text = video.titleString
    self.descriptionLabel.text = video.descriptionString
    self.layoutLabels()
    self.refreshFavoritesStatus()
  }
  
  func refreshFavoritesStatus(){
    if(self.selectedVideo != nil) {
      self.favoriteLabel.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
      self.favoritesButton.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), forState: .Normal)
    }
  }
  
  func onExpandDescription() {
    if(self.selectedVideo != nil) {
      let alertVC = self.storyboard?.instantiateViewControllerWithIdentifier("ScrollableTextAlertVC") as! ScrollableTextAlertVC
      alertVC.configWithText(self.selectedVideo.descriptionString, header: self.selectedShow.titleString, title: self.selectedVideo.titleString)
      self.navigationController?.presentViewController(alertVC, animated: true, completion: nil)
    }
  }
  
  @IBAction func onFavorites(sender: AnyObject) {
    if(self.selectedVideo != nil) {
      self.selectedVideo.toggleFavorite()
      self.refreshFavoritesStatus()
    }
  }
  
  @IBAction func onSubscribe(sender: AnyObject) {
    self.playVideo(self.selectedVideo, playlist: self.videos)
  }
  
  func onPurchased() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
