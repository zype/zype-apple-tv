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
    
    // MARK: - Properties
    
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subscribeLabel.text = localized("ShowDetails.SubscribedButton")
        self.favoriteLabel.text = localized("ShowDetails.Favorite")
        self.descriptionLabel.textColor = StyledLabel.kBaseColor
        self.descriptionView.onSelected = {[unowned self] in
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
        if let path = self.indexPathForselectedVideo() {
            self.collectionVC.collectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted), object: nil)
        
        if Const.kNativeSubscriptionEnabled {
            InAppPurchaseManager.sharedInstance.refreshSubscriptionStatus()
        }
        self.refreshButtons()
    }
    
    // MARK: - Layout & Focus
    
    override func viewWillLayoutSubviews() {
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
        if self.selectedVideo != nil {
            return IndexPath(row: self.videos.index(of: self.selectedVideo)!, section: 0)
        }
        return nil
    }
    
    func layoutLabels(){
        for label in self.labelsView.subviews {
            if label.isKind(of: UILabel.self) {
                label.width = self.labelsView.width
            }
        }
        self.subTitleLabel.top = self.titleLabel.bottom + ShowDetailsVC.kSubtitleTopMargin
        self.descriptionView.top = self.subTitleLabel.bottom
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        self.focusGuide.preferredFocusedView = self.preferredFocusedView
    }
    
    override func onItemFocused(_ item: CollectionLabeledItem, section: CollectionSection?) {
        self.onVideoFocused(item.object as! VideoModel)
    }
    
    override func onItemSelected(_ item: CollectionLabeledItem, section: CollectionSection?) {
        self.onSubscribe(self)
    }
    
    func onVideoFocused(_ video: VideoModel) {
        self.selectedVideo = video
        self.posterImage.configWithURL(video.posterURL() as URL?)
        self.subTitleLabel.text = video.titleString
        self.descriptionLabel.text = video.descriptionString
        self.layoutLabels()
        self.refreshButtons()
    }
    
    // MARK: - Get Data
    
    func loadVideos() {
        self.selectedShow.getVideos(Date.distantPast, completion: {[unowned self] (videos: Array<VideoModel>?, error: NSError?) -> Void in
            self.videos = videos
            
            let videosCount = videos?.count ?? 0
            let format = localized(videosCount == 1 ? "ShowDetails.Episode" : "ShowDetails.EpisodesCount")
            self.episodesCountLabel.text = String(format: format, arguments: [videosCount])
            
            let section = CollectionSection()
            section.items = CollectionContainerVC.videosToCollectionItems(videos)
            self.collectionVC.configWithSection(section)
        })
    }
    
    // MARK: - Actions
    
    func onExpandDescription() {
        if self.selectedVideo != nil {
            let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "ScrollableTextAlertVC") as! ScrollableTextAlertVC
            alertVC.configWithText(self.selectedVideo.descriptionString, header: self.selectedVideo.titleString, title: "")
            self.navigationController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSubscribe(_ sender: AnyObject) { // Buttons: [✓] [ ] [ ]
        let resume = requiresResumeButton()
        
        if self.selectedVideo.subscriptionRequired == false {
            self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: resume)
        }
        else {
            if Const.kNativeSubscriptionEnabled == true {
                if !InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                    let purchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
                    
                    InAppPurchaseManager.sharedInstance.requestProducts({ _ in
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(ShowDetailsVC.onPurchased),
                                                               name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                               object: nil)
                        self.navigationController?.present(purchaseVC, animated: true, completion: nil)
                    })
                }
                else {
                    self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: resume)
                }
            }
            else {
                // Zype subcription here
                self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: resume)
            }
        }
    }
    
    @IBAction func onFavorites(_ sender: AnyObject) { // Buttons: [ ] [✓] [ ]
        if self.selectedVideo != nil {
            if requiresResumeButton() {
                self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: false)
            }
            else {
                self.favoritesPressed()
            }
        }
    }
    
    @IBAction func onResume(_ sender: AnyObject) { // Buttons: [ ] [ ] [✓]
        if self.selectedVideo != nil {
            if requiresResumeButton() {
                self.favoritesPressed()
            }
        }
    }
    
    // MARK: - Buttons
    
    fileprivate func refreshButtons() {
        guard self.selectedVideo != nil else { return }
        
        if self.selectedVideo.subscriptionRequired {
            if Const.kNativeSubscriptionEnabled {
                if InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                    self.refreshPlayableButtons()
                }
                else {
                    self.refreshUnplayableButtons()
                }
            }
            else { // Native not enabled
                if ZypeUtilities.isDeviceLinked() {
                    self.refreshPlayableButtons()
                }
                else {
                    self.refreshUnplayableButtons()
                }
            }
        }
        else { // Subscription not required
            self.refreshPlayableButtons()
        }
    }
    
    fileprivate func refreshPlayableButtons() {
        if requiresResumeButton() {
            self.resumeButton.isHidden = false
            self.loadFavoritesButton(for: self.resumeLabel, and: self.resumeButton)
            self.favoriteLabel.text = "Play"
            self.favoritesButton.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
            self.subscribeLabel.text = "Resume"
            self.subscribeButton.setBackgroundImage(UIImage(named: "Resume"), for: .normal)
        }
        else {
            self.resumeButton.isHidden = true
            self.resumeLabel.text = ""
            self.loadFavoritesButton(for: self.favoriteLabel, and: self.favoritesButton)
            self.subscribeLabel.text = "Play"
            self.subscribeButton.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
        }
    }
    
    fileprivate func refreshUnplayableButtons() { // requires subscription to play
        self.subscribeButton.setBackgroundImage(UIImage(named: "SubscribeFocused"), for: .normal)
        self.subscribeLabel.text = localized("ShowDetails.SubscribeButton")
        self.loadFavoritesButton(for: self.favoriteLabel, and: favoritesButton)
        self.resumeButton.isHidden = true
        self.resumeLabel.text = ""
    }
    
    fileprivate func requiresResumeButton() -> Bool {
        if let _ = userDefaults.object(forKey: "\(selectedVideo.getId())") {
            if !self.selectedVideo.onAir {
                return true
            }
        }
        return false
    }
    
    fileprivate func loadFavoritesButton(for label: UILabel, and button: FocusableButton) {
        label.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
        button.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), for: .normal)
    }
    
    fileprivate func favoritesPressed() {
        if Const.kFavoritesViaAPI {
            guard ZypeAppleTVBase.sharedInstance.consumer?.isLoggedIn == true else {
                ZypeUtilities.presentLoginVC(self)
                return
            }
            
            if !self.selectedVideo.isInFavorites() {
                ZypeAppleTVBase.sharedInstance.setFavorite(self.selectedVideo, shouldSet: true, completion: {(success: Bool, error: NSError?) -> Void in
                    print("favorted")
                })
            }
            else {
                ZypeAppleTVBase.sharedInstance.setFavorite(self.selectedVideo, shouldSet: false, completion: {(success: Bool, error: NSError?) -> Void in
                    print("unfavorited")
                })
            }
        }
        self.selectedVideo.toggleFavorite()
        self.refreshButtons()
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
}
