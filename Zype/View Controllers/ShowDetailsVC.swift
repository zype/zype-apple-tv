//
//  ShwDetailsVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/9/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

protocol ChangeVideoDelegate {
    func changeFocusVideo(_ video: VideoModel)
}

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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyLiveLabel: StyledLabel!
    
    @IBOutlet weak var button0: FocusableButton!
    @IBOutlet weak var button1: FocusableButton!
    @IBOutlet weak var button2: FocusableButton!
    @IBOutlet weak var button3: FocusableButton!
    @IBOutlet weak var button4: FocusableButton!
    @IBOutlet weak var button5: FocusableButton!
    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
    var selectedShow: PlaylistModel!
    var selectedVideo: VideoModel!
    var videos: Array<VideoModel>!
    var focusGuide: UIFocusGuide!
    let userDefaults = UserDefaults.standard
    var actionables = [Actionable]()
    var currentButtonTypes = [ButtonType]()
    var entitledVideos = [FavoriteModel]()
    var isLive: Bool = false

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
        self.button4.label = self.label4

        self.posterImage.shouldAnimate = true
        if self.selectedShow != nil {
            self.titleLabel.text = self.selectedShow.titleString
            self.loadVideos()
        } else {
            self.collectionVC.activityIndicator.stopAnimating()
            if !self.isLive {
                self.onVideoFocused(self.selectedVideo)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
    
    func reloadCollection() {
        self.collectionVC.isConfigurated = false
        self.collectionVC.collectionView?.reloadData()
        if self.selectedShow != nil {
            self.loadVideos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let path = self.indexPathForselectedVideo() {
            self.collectionVC.collectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
        }

        if Const.kNativeTvod {
            self.fetchVideoEntitlements {
                self.refreshButtons()
            }
        } else {
            self.refreshButtons()
        }

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted), object: nil)
        
        if Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal {
            InAppPurchaseManager.sharedInstance.refreshSubscriptionStatus()
        }
        
        if self.isLive {
            self.loadLiveVideo()
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
            if self.selectedShow == nil {
                return self.button0
            }
            return super.preferredFocusedView
        }
    }
    
    func indexPathForselectedVideo() -> IndexPath? {
        if self.selectedVideo != nil && self.selectedShow != nil {
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

        if Const.kNativeTvod {
            self.fetchVideoEntitlements {
                self.refreshButtons()
            }
        } else {
            self.refreshButtons()
        }
    }
    
    // MARK: - Get Data
    
    func loadLiveVideo() {
        self.detailsView.isHidden = true
        self.containerView.isHidden = true
        self.emptyLiveLabel.isHidden = true
        self.activityIndicator.startAnimating()
        
        let queryModel = QueryVideosModel(categoryValue: nil, exceptCategoryValue: nil, playlistId: "", searchString: "", page: 0, perPage: 1)
        queryModel.videoID = Const.kLiveVideoID
        ZypeAppleTVBase.sharedInstance.getVideos(queryModel) { (videos, error) in
            self.activityIndicator.stopAnimating()
            
            if error == nil && videos != nil && (videos?.count)! > 0 {
                self.detailsView.isHidden = false
                self.containerView.isHidden = false
                
                self.selectedVideo = videos!.first!
                self.onVideoFocused(self.selectedVideo)
                self.refreshButtons()
            } else {
                self.emptyLiveLabel.isHidden = false
                print(error?.localizedDescription ?? "Error: Pager Video Can't Play")
            }
        }
    }
    
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
    
    // Preload all user entitlements for Native TVOD. Called when view appears/reappears
    func fetchVideoEntitlements(completion: @escaping () -> Void) {
        self.entitledVideos = []
        ZypeAppleTVBase.sharedInstance.getMyLibrary { (videoLib, err) in

            // Note: getMyLibrary() repurposes the FavoriteModel
            //  - FavoriteModel.objectID == video id
            guard let vids = videoLib as Array<FavoriteModel>? else {
                completion()
                return
            }

            self.entitledVideos = vids
            completion()
        }
    }

    // MARK: - Buttons
    
    fileprivate func refreshButtons() {
        if self.selectedVideo == nil {
            return
        }
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
            case .purchase:
                actionable.button.setBackgroundImage(UIImage(named: "SubscribeFocused"), for: .normal)
                actionable.label.text = localized("ShowDetails.PurchaseButton")
            case .favorite:
                actionable.button.setBackgroundImage(UIImage(named: self.selectedVideo.isInFavorites() ? "FavoritesRemoveFocused" : "FavoritesAddFocused"), for: .normal)
                actionable.label.text = localized(self.selectedVideo.isInFavorites() ? "ShowDetails.Unfavorite" : "ShowDetails.Favorite")
            case .watchTrailer:
                actionable.button.setBackgroundImage(UIImage(named: "WatchTrailer"), for: .normal)
                actionable.label.text = localized("ShowDetails.WatchTrailer")
            case .signup:
                actionable.button.setBackgroundImage(UIImage(named: "Subscribed"), for: .normal)
                actionable.label.text = localized("ShowDetails.SignupButton")
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

    @IBAction func onButton4(_ sender: AnyObject) { // Buttons: [ ] [ ] [ ] [ ] [✓][ ]
        self.handleButtonType(self.currentButtonTypes[4])
    }
    
    @IBAction func onButton5(_ sender: AnyObject) { // Buttons: [ ] [ ] [ ] [ ][ ] [✓]
        self.handleButtonType(self.currentButtonTypes[5])
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
        case .purchase:
            self.handlePurchase()
        case .favorite:
            self.handleFavorites()
        case .watchTrailer:
            self.handleTrailer()
        case .signup:
            self.handleRegisteration()
        }
    }
    
    fileprivate func handleResume() {
        self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: true, startTime: nil, endTime: nil, completionDelegate: self)
    }
    
    fileprivate func handlePlay() {
        self.playVideo(self.selectedVideo, playlist: self.videos, isResuming: false, startTime: nil, endTime: nil, completionDelegate: self)
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
        
        // TODO: add logic for fetching video marketplace id / skus
        let dict = UserDefaults.standard.object(forKey: Const.kSubscriptionSettings) as! [String: String]
        var productIds = [String]()
        for product in dict {
            productIds.append(product.key)
        }
//        let productId: String = "product1"

        InAppPurchaseManager.sharedInstance.requestProducts(productIds, withCallback: { _ in
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(ShowDetailsVC.onPurchased),
                                                   name: NSNotification.Name(rawValue: InAppPurchaseManager.kPurchaseCompleted),
                                                   object: nil)
            purchaseVC.setupAssociatedVideo(video: self.selectedVideo)
            self.navigationController?.present(purchaseVC, animated: true, completion: nil)
        })
    }
    
    fileprivate func handlePurchase() {
        if Const.kNativeTvod {
            self.presentPurchaseVC()
        }
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
    
    fileprivate func handleTrailer() {
        if let previewIDs = selectedVideo.fullJson["preview_ids"] as? Array<String>, previewIDs.count > 0 {
            
            let queryModel = QueryVideosModel(categoryValue: nil, exceptCategoryValue: nil, playlistId: "", searchString: "", page: 0, perPage: 1)
            queryModel.videoID = previewIDs[0]
            ZypeAppleTVBase.sharedInstance.getVideos(queryModel) { (videos, error) in
                if error == nil && videos != nil && (videos?.count)! > 0 {
                    self.playVideo(videos![0])
                } else {
                    print(error?.localizedDescription ?? "Error: Watch Trailer")
                }
            }
            
        }
    }
    
    fileprivate func handleRegisteration() {
        ZypeUtilities.presentRegisterVC(self)
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
        let actionable4 = Actionable(button: button4, label: label4)
        let actionable5 = Actionable(button: button5, label: label5)
        
        actionables = [actionable0, actionable1, actionable2, actionable3, actionable4, actionable5]
    }
    
    enum ButtonType {
        case resume
        case play
        case subscribe
        case watchAdFree
        case purchase
        case favorite
        case watchTrailer
        case signup
    }
    
    func getCurrentActionables() {
        var buttons = [ButtonType]()
        
        if requiresResumeButton() {
            buttons.append(.resume)
        }
        
        let playButton = getPlayMonetizationButton()
        if playButton == .subscribe || playButton == .purchase {
            buttons = []
        }
        buttons.append(playButton)
        
        if requiresSwafButton() {
            buttons.append(.watchAdFree)
        }
        
        if let firstButton = buttons.first {
            if requiresPurchaseButton() && firstButton != .purchase {
                buttons.append(.purchase)
            }
        }
        
        buttons.append(.favorite)
        
        if requiresTrailerButton() {
            buttons.append(.watchTrailer)
        }
        
        self.currentButtonTypes = buttons
    }
    
    fileprivate func getPlayMonetizationButton() -> ButtonType {
        if selectedVideo == nil {
            return .play
        }
        if selectedVideo.registrationRequired {
            if !ZypeUtilities.isDeviceLinked() {
                return .signup
            }
        }
        else if selectedVideo.subscriptionRequired {
            if Const.kNativeTvod && selectedVideo.purchaseRequired && userHasEntitlement() {
                return .play
            }
            else if Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal {                
                if !InAppPurchaseManager.sharedInstance.lastSubscribeStatus {
                    return .subscribe
                }
            }
            else {
                if !ZypeUtilities.isDeviceLinked() {
                    return .subscribe
                }
            }
        } else if selectedVideo.purchaseRequired {
            if Const.kNativeTvod && selectedVideo.purchaseRequired && !userHasEntitlement() {
                return .purchase
            }
        }
        return .play
    }
    
    fileprivate func requiresResumeButton() -> Bool {
        if self.selectedVideo != nil, let _ = userDefaults.object(forKey: "\(selectedVideo.getId())") {
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

    fileprivate func requiresPurchaseButton() -> Bool {
        if (Const.kNativeTvod && selectedVideo.purchaseRequired) {
            var requiresPurchase: Bool = true

            if userHasEntitlement() {
                requiresPurchase = false
            }

            return requiresPurchase
        } else {
            return false
        }
    }
    
    fileprivate func requiresTrailerButton() -> Bool {
        if selectedVideo != nil, let previewIDs = selectedVideo.fullJson["preview_ids"] as? Array<String>,
            previewIDs.count > 0 {
            return true
        }
        return false
    }

    fileprivate func userHasEntitlement() -> Bool {
        for vid in entitledVideos {
            if vid.objectID == selectedVideo.getId() {
                return true
            }
        }
        return false
    }
}

extension ShowDetailsVC: ChangeVideoDelegate {
    func changeFocusVideo(_ video: VideoModel) {
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.1)
            DispatchQueue.main.async {
                self.selectedVideo = video
                if let path = self.indexPathForselectedVideo() {
                    self.collectionVC.collectionView?.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
                }
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }
}
