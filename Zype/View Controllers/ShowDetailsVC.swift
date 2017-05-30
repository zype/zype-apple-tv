//
//  ShwDetailsVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class ShowDetailsVC: CollectionContainerVC {
    
    static let kDescriptionTopMargin: CGFloat = 0.0
    static let kSubtitleTopMargin: CGFloat = -15.0
    
    @IBOutlet weak var posterImage: URLImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var labelsView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var favoritesButton: FocusableButton!
    @IBOutlet weak var subscribeButton: FocusableButton!
    @IBOutlet weak var resumeButton: FocusableButton!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var resumeLabel: UILabel!
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var episodesCountLabel: StyledLabel!
    @IBOutlet weak var descriptionView: FocusableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var selectedShow: PlaylistModel!
    var selectedVideo: VideoModel!
    var videos: Array<VideoModel>!
    var focusGuide: UIFocusGuide!
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeLabel.text = localized("ShowDetails.SubscribedButton")
        self.favoriteLabel.text = localized("ShowDetails.Favorite")
        self.descriptionLabel.textColor = StyledLabel.kBaseColor
        self.descriptionView.onSelected = {
            self.onExpandDescription()
        }
        self.subscribeButton.setBackgroundImage(UIImage(named: "Subscribed"), for: UIControlState())
        self.favoritesButton.setBackgroundImage(UIImage(named: "FavoritesAddFocused"), for: UIControlState())
        
        let distance = (self.containerView.top - self.detailsView.bottom) / 2
        
        self.focusGuide = UIFocusGuide()
        self.view.addLayoutGuide(focusGuide)
        self.focusGuide.leftAnchor.constraint(equalTo: self.detailsView.leftAnchor).isActive = true
        self.focusGuide.bottomAnchor.constraint(equalTo: self.containerView.topAnchor, constant: -distance).isActive = true
        self.focusGuide.topAnchor.constraint(equalTo: self.detailsView.bottomAnchor).isActive = true
        self.focusGuide.rightAnchor.constraint(equalTo: self.detailsView.rightAnchor).isActive = true
        
        let favoritesButtonGuide = UIFocusGuide()
        self.view.addLayoutGuide(favoritesButtonGuide)
        favoritesButtonGuide.leftAnchor.constraint(equalTo: self.detailsView.leftAnchor).isActive = true
        favoritesButtonGuide.bottomAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        favoritesButtonGuide.topAnchor.constraint(equalTo: self.detailsView.bottomAnchor, constant: distance).isActive = true
        favoritesButtonGuide.rightAnchor.constraint(equalTo: self.detailsView.rightAnchor).isActive = true
        favoritesButtonGuide.preferredFocusedView = self.favoritesButton
        
        self.favoritesButton.label = self.favoriteLabel
        self.subscribeButton.label = self.subscribeLabel
        self.resumeButton.label = self.resumeLabel
        
        self.posterImage.shouldAnimate = true
        self.titleLabel.text = self.selectedShow.titleString
        self.loadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshButtons()
        if let path = self.indexPathForselectedVideo() {
            self.collectionVC.collectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        self.layoutLabels()
    }
    
    override weak var preferredFocusedView: UIView? {
        get {
            if let path = self.indexPathForselectedVideo() {
                return self.collectionVC.collectionView?.cellForItem(at: path)
            }
            return super.preferredFocusedView
        }
    }
    
    func indexPathForselectedVideo() -> IndexPath? {
        if(self.selectedVideo != nil) {
            return IndexPath(row: self.videos.index(of: self.selectedVideo)!, section: 0)
        }
        return nil
    }
    
    func layoutLabels(){
        for label in self.labelsView.subviews {
            if(label.isKind(of: UILabel.self)) {
                label.width = self.labelsView.width
                // label.sizeToFit()
            }
        }
        self.subTitleLabel.top = self.titleLabel.bottom + ShowDetailsVC.kSubtitleTopMargin
        self.descriptionView.top = self.subTitleLabel.bottom
        //    self.descriptionView.height = self.labelsView.height - self.descriptionView.top
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        self.focusGuide.preferredFocusedView = self.preferredFocusedView
    }
    
    override func onItemFocused(_ item: CollectionLabeledItem, section: CollectionSection?) {
        self.onVideoFocused(item.object as! VideoModel)
    }
    
    override func onItemSelected(_ item: CollectionLabeledItem, section: CollectionSection?) {
        self.playVideo(item.object as! VideoModel, playlist: section?.allObjects() as? Array<VideoModel>)
    }
    
    func loadVideos() {
        self.selectedShow.getVideos(Date.distantPast, completion: {[unowned self] (videos: Array<VideoModel>?, error: NSError?) -> Void in
            self.videos = videos
            let videosCount = videos?.count ?? 0
            self.episodesCountLabel.text = String(format: localized(videosCount == 1 ? "ShowDetails.Episode" : "ShowDetails.EpisodesCount"), arguments: [videosCount])
            let section = CollectionSection()
            section.items = CollectionContainerVC.videosToCollectionItems(videos)
            self.collectionVC.configWithSection(section)
        })
    }
    
    func onVideoFocused(_ video: VideoModel) {
        self.selectedVideo = video
        self.posterImage.configWithURL(video.posterURL() as URL?)
        self.subTitleLabel.text = video.titleString
        self.descriptionLabel.text = video.descriptionString
        self.layoutLabels()
        self.refreshButtons()
    }
    
    func requiresResumeButton() -> Bool {
        if let _ = userDefaults.object(forKey: "\(selectedVideo.getId())") {
            if !self.selectedVideo.onAir {
                return true
            }
        }
        return false
    }
    
    func refreshButtons() {
        if (self.selectedVideo != nil) {
            if requiresResumeButton() {
                self.resumeButton.isHidden = false
                self.resumeLabel.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
                self.resumeButton.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), for: .normal)
                self.favoriteLabel.text = "Play"
                self.favoritesButton.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
                self.subscribeLabel.text = "Resume"
                self.subscribeButton.setBackgroundImage(UIImage(named: "Resume"), for: .normal)
            }
            else {
                self.favoriteLabel.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
                self.favoritesButton.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), for: .normal)
                self.resumeButton.isHidden = true
                self.resumeLabel.text = ""
                self.subscribeLabel.text = "Play"
                self.subscribeButton.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
            }
        }
    }
    
    func onExpandDescription() {
        if (self.selectedVideo != nil) {
            let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "ScrollableTextAlertVC") as! ScrollableTextAlertVC
            alertVC.configWithText(self.selectedVideo.descriptionString, header: self.selectedVideo.titleString, title: "")
            self.navigationController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onFavorites(_ sender: AnyObject) {
        if (self.selectedVideo != nil) {
            if requiresResumeButton() {
                self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: false)
            }
            else {
                self.selectedVideo.toggleFavorite()
                self.refreshButtons()
            }
        }
    }
    
    @IBAction func onSubscribe(_ sender: AnyObject) {
        if (self.selectedVideo != nil) {
            if requiresResumeButton() {
                self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: true)
            }
            else {
                self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: false)
            }
        }
    }
    
    @IBAction func onResume(_ sender: AnyObject) {
        if (self.selectedVideo != nil) {
            if requiresResumeButton() {
                self.selectedVideo.toggleFavorite()
                self.refreshButtons()
            }
        }
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
