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
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var episodesCountLabel: StyledLabel!
    @IBOutlet weak var descriptionView: FocusableView!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var button0: FocusableButton!
    @IBOutlet weak var button1: FocusableButton!
    @IBOutlet weak var button2: FocusableButton!
    @IBOutlet weak var button3: FocusableButton!
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    var selectedShow: PlaylistModel!
    var selectedVideo: VideoModel!
    var videos: Array<VideoModel>!
    var focusGuide: UIFocusGuide!
    let userDefaults = UserDefaults.standard
    var actionables = [Actionable]()
    var currentButtonTypes = [ButtonType]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionLabel.textColor = StyledLabel.kBaseColor
        self.descriptionView.onSelected = {[unowned self] in
            self.onExpandDescription()
        }
        
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
        favoritesButtonGuide.preferredFocusedView = self.button1
        
        self.createActionables()
        self.button1.label = self.label1
        self.button0.label = self.label0
        self.button2.label = self.label2
        self.button3.label = self.label3
        
        self.posterImage.shouldAnimate = true
        self.titleLabel.text = self.selectedShow.titleString
        self.loadVideos()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
    
    func reloadCollection() {
        self.collectionVC.isConfigurated = false
        self.collectionVC.collectionView?.reloadData()
        self.loadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let path = self.indexPathForselectedVideo() {
            self.collectionVC.collectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
        }
        self.refreshButtons()
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted), object: nil)
        
        if Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal {
            InAppPurchaseManager.sharedInstance.refreshSubscriptionStatus()
        }
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
        self.onButton0(self)
    }
    
    func onVideoFocused(_ video: VideoModel) {
        self.selectedVideo = video
        self.posterImage.configWithURL(video.posterURL() as URL?, nil)
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
            section.thumbnailLayout = self.selectedShow.thumbnailLayout
            
            if self.selectedShow.thumbnailLayout == .poster {
                let topSectionInset: CGFloat = 120.0
                let episodesCountLabelPaddingX: CGFloat = 300.0
                let episodesCountLabelPaddingY: CGFloat = 20.0
                section.insets.top = topSectionInset
                section.cellSize = Const.kCollectionCellMiniPosterSize
                self.episodesCountLabel.center = CGPoint.init(x: self.episodesCountLabel.origin.x + episodesCountLabelPaddingX, y: self.episodesCountLabel.origin.y + episodesCountLabelPaddingY)
            }
            self.collectionVC.configWithSection(section)
        })
    }
    
    // MARK: - Buttons
    
    fileprivate func refreshButtons() {
        self.getCurrentActionables()
        for each in self.actionables {
            each.button.isHidden = true
            each.label.isHidden = true
        }
        
        for i in 0..<self.currentButtonTypes.count {
            let action = self.currentButtonTypes[i]
            let actionable = self.actionables[i]
            
            actionable.button.isHidden = false
            actionable.label.isHidden = false
            
            switch action {
            case .resume:
                actionable.button.setBackgroundImage(UIImage(named: "Resume"), for: .normal)
                actionable.label.text = localized("ShowDetails.Resume")
            case .play:
                actionable.button.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
                actionable.label.text = localized("ShowDetails.SubscribedButton")
            case .subscribe:
                actionable.button.setBackgroundImage(UIImage(named: "SubscribeFocused"), for: .normal)
                actionable.label.text = localized("ShowDetails.SubscribeButton")
            case .watchAdFree:
                actionable.button.setBackgroundImage(UIImage(named: "SubscribeFocused"), for: .normal)
                actionable.label.text = localized("ShowDetails.SubscribeToWatchAdFree")
            case .favorite:
                actionable.button.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), for: .normal)
                actionable.label.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
            }
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func onButton0(_ sender: AnyObject) { // Buttons: [✓] [ ] [ ] [ ]
        self.handleButtonType(self.currentButtonTypes[0])
    }
    
    @IBAction func onButton1(_ sender: AnyObject) { // Buttons: [ ] [✓] [ ] [ ]
        self.handleButtonType(self.currentButtonTypes[1])
    }
    
    @IBAction func onButton2(_ sender: AnyObject) { // Buttons: [ ] [ ] [✓] [ ]
        self.handleButtonType(self.currentButtonTypes[2])
    }
    
    @IBAction func onButton3(_ sender: AnyObject) { // Buttons: [ ] [ ] [ ] [✓]
        self.handleButtonType(self.currentButtonTypes[3])
    }
    
    func onExpandDescription() {
        if self.selectedVideo != nil {
            let alertVC = self.storyboard?.instantiateViewController(withIdentifier: "ScrollableTextAlertVC") as! ScrollableTextAlertVC
            alertVC.configWithText(self.selectedVideo.descriptionString, header: self.selectedVideo.titleString, title: "")
            self.navigationController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func onPurchased() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Utilities
    
    fileprivate func handleButtonType(_ type: ButtonType) {
        switch type {
        case .resume:
            self.handleResume()
        case .play:
            self.handlePlay()
        case .subscribe:
            self.handleSubscribe()
        case .watchAdFree:
            self.handleSubscribe()
        case .favorite:
            self.handleFavorites()
        }
    }
    
    fileprivate func handleResume() {
        self.playVideo(self.selectedVideo, playlist: self.videos)
    }
    
    fileprivate func handlePlay() {
        self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: false)
    }
    
    fileprivate func handleSubscribe() {
        if Const.kNativeSubscriptionEnabled {
            if !InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                self.presentPurchaseVC()
                return
            }
        }
        if Const.kNativeToUniversal {
            if !InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                self.presentPurchaseVC()
            }
        }
        else {
            ZypeUtilities.presentLoginVC(self)
        }
    }
    
    fileprivate func presentPurchaseVC() {
        let purchaseVC = self.storyboard?.instantiateViewController(withIdentifier: "PurchaseVC") as! PurchaseVC
        
        InAppPurchaseManager.sharedInstance.requestProducts({ _ in
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(ShowDetailsVC.onPurchased),
                                                   name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                   object: nil)
            self.navigationController?.present(purchaseVC, animated: true, completion: nil)
        })
    }
    
    fileprivate func handleFavorites() {
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
}


extension ShowDetailsVC {
    struct Actionable {
        var button: FocusableButton
        var label: UILabel
    }
    
    fileprivate func createActionables() {
        let actionable0 = Actionable(button: button0, label: label0)
        let actionable1 = Actionable(button: button1, label: label1)
        let actionable2 = Actionable(button: button2, label: label2)
        let actionable3 = Actionable(button: button3, label: label3)
        
        actionables = [actionable0, actionable1, actionable2, actionable3]
    }
    
    enum ButtonType {
        case resume
        case play
        case subscribe
        case watchAdFree
        case favorite
    }
    
    func getCurrentActionables() {
        var buttons = [ButtonType]()
        
        if requiresResumeButton() {
            buttons.append(.resume)
        }
        
        let playButton = getPlaySubscribeButton()
        if playButton == .subscribe {
            buttons = []
        }
        buttons.append(playButton)
        
        if requiresSwafButton() {
            buttons.append(.watchAdFree)
        }
        
        buttons.append(.favorite)
        
        self.currentButtonTypes = buttons
    }
    
    fileprivate func getPlaySubscribeButton() -> ButtonType {
        if selectedVideo.subscriptionRequired {
            if Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal {
                if !InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                    return .subscribe
                }
            }
            else {
                if !ZypeUtilities.isDeviceLinked() {
                    return .subscribe
                }
            }
        }
        return .play
    }
    
    fileprivate func requiresResumeButton() -> Bool {
        if let _ = userDefaults.object(forKey: "\(selectedVideo.getId())") {
            if !self.selectedVideo.onAir {
                return true
            }
        }
        return false
    }
    
    fileprivate func requiresSwafButton() -> Bool {
        if Const.kNativeSubscriptionEnabled {
            return false
        }
        
        if ZypeUtilities.isDeviceLinked() {
            return false
        }
        
        return Const.kSubscribeToWatchAdFree
    }

}
