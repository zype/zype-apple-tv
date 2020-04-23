//
//  ViewController.swift
//  UITest
//
//  Created by Eugene Lizhnyk on 10/8/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

class HomeVC: CollectionContainerVC, UINavigationControllerDelegate {
    
    static let kShowDetailsSegueID = "ShowDetails"
    
    @IBOutlet weak var collectionWrapperView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabel: StyledLabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var initFocusView: TransparentFocusableView!
    
    static let kMaxVideosInSection = 20
    
    var pagerVC: BaseCollectionVC!
    var selectedVideo: VideoModel!
    var selectedShow: PlaylistModel!
    var playlists = [PlaylistModel]()
    var playlistParent: PlaylistModel?
    var playlistParentAsId: String?
    var secondPress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.reloadButton.setTitle(localized("Home.ReloadButton"), for: UIControlState())
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "ready_to_load_playlists"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection), name: NSNotification.Name(rawValue: kZypeReloadScreenNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
        self.secondPress = false
        
        if Const.kNativeSubscriptionEnabled || Const.kNativeToUniversal {
            InAppPurchaseManager.sharedInstance.refreshSubscriptionStatus()
        }
    }
    
    override weak var preferredFocusedView: UIView? {
        get {
            if self.playlistParentAsId == nil && self.selectedVideo == nil {
                if let sections = self.collectionVC.sections, sections.count > 0 {
                    let controllerSection = sections[0]
                    if let first = controllerSection.controller as? BaseCollectionVC,
                        let cell = first.collectionView?.cellForItem(at: IndexPath(item: 0, section: 0)) {
                        initFocusView.isHidden = true
                        return cell
                    }
                }
            }
            return super.preferredFocusedView
        }
    }
    
    func reloadCollection() {
        self.collectionVC.isConfigurated = false
        
        for section in self.collectionVC.sections {
            section.controller = nil
        }
    }
    
    func playlistByID(_ ID: String) -> PlaylistModel? {
        for playlist in self.playlists {
            if(playlist.ID == ID) {
                return playlist
            }
        }
        return nil
    }
    
    func reloadData() {
        self.hideErrorInfo()
        let queryModel = QueryPlaylistsModel()
        
        if self.playlistParent != nil {
            queryModel.parentId = self.playlistParent!.pId
        }
        else {
            if self.playlistParentAsId != nil {
                queryModel.parentId = self.playlistParentAsId!
            }
            else {
                let rootPlaylistId = UserDefaults.standard.object(forKey: Const.kDefaultsRootPlaylistId)
                if rootPlaylistId != nil {
                    queryModel.parentId = (rootPlaylistId as? String)!
                }
                else {
                    queryModel.parentId = ""
                }
            }
        }
        
        ZypeAppleTVBase.sharedInstance.getPlaylists(queryModel, completion: {[unowned self] (playlists: Array<PlaylistModel>?, error: NSError?) in
            if error == nil && playlists != nil {
                self.playlists = playlists!
                
                self.getFeaturedVideos(callback: {[unowned self] in
                    self.fillSections()
                })    
            }
            else {
                self.fillSections()
                self.showErrorInfo(error?.localizedDescription)
            }
        })
    }
    
    func playlistForZObject(_ object: ZobjectModel) -> PlaylistModel? {
        let playlistID = object.getStringValue("playlistid")
        if let show = self.playlistByID(playlistID) {
            return show
        }
        return nil
    }
    
    func getFeaturedVideos(callback: @escaping () -> Void) {
        //configure header for child playlists
        if self.playlistParentAsId != nil {
            self.addPager()
            callback()
            return
        }
        //use only for Home Screen
        let type = QueryZobjectsModel()
        type.zobjectType = "top_playlists"
        type.anyQueryString = "&sort=priority&order=desc"
        ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
            if let _ = objects, objects!.count > 0 {
                
                let items = CollectionContainerVC.featuresToCollectionItems(objects)
                let section = CollectionSection()
                section.isPager = true
                section.items = items
                section.insets.top = 0
                section.insets.bottom = 0
                section.horizontalSpacing = Const.kCollectionPagerHorizontalSpacing
                section.cellSize = CGSize(width: 1740, height: 700)//490 //original image is 1450 x 630 //1920
                
                if self.pagerVC == nil {
                    self.pagerVC = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
                    self.pagerVC.view.height = 700
                    self.pagerVC.isInfinityScrolling = true
                    self.collectionVC.addChildViewController(self.pagerVC)
                    self.pagerVC.didMove(toParentViewController: self.collectionVC)
                    self.pagerVC.itemSelectedCallback = { [unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                        guard self.secondPress != true else { return }
                        let zObject = (item as! PagerCollectionItem).object as! ZobjectModel
                        if zObject.getStringValue("playlistid") == "" && zObject.getStringValue("videoid") == "" {
                            return
                        }
                        
                        if item.object is VideoModel {
                            self.playVideo(item.object as! VideoModel)
                            return
                        }
                        
                        if zObject.getStringValue("videoid") != "" {
                            let queryModel = QueryVideosModel(categoryValue: nil, exceptCategoryValue: nil, playlistId: "", searchString: "", page: 0, perPage: 1)
                            queryModel.videoID = zObject.getStringValue("videoid")
                            ZypeAppleTVBase.sharedInstance.getVideos(queryModel) { (videos, error) in
                                if error == nil && videos != nil && (videos?.count)! > 0 {
                                    if zObject.getBoolValue("autoplay") == true {
                                        self.playVideo(videos!.first!)
                                    } else {
                                        self.selectedVideo = videos!.first!
                                        self.selectedShow = nil
                                        self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: self)
                                    }
                                } else {
                                    print(error?.localizedDescription ?? "Error: Pager Video Can't Play")
                                }
                            }
                            return
                        }
                        
                        if let playlist = self.playlistForZObject(zObject) { // if we have the playlist
                            self.performFeaturedPlaylistSegue(with: playlist, and: zObject, at: section)
                        }
                        else { //load playlist that is not on the screen with playlists
                            let playlistId = zObject.getStringValue("playlistid")
                            ZypeAppleTVBase.sharedInstance.getPlaylist(with: playlistId, completion: { (playlist, error) in
                                if let playlist = playlist, playlist.count > 0 {
                                    let play = playlist[0]
                                    self.performFeaturedPlaylistSegue(with: play, and: zObject, at: section)
                                }
                            })
                        }
                    }
                    self.pagerVC.configWithSection(section)
                    DispatchQueue.global().async {
                        Thread.sleep(forTimeInterval: 0.5)
                        DispatchQueue.main.async {
                            TabBarVC.openingApp = true
                            self.setNeedsFocusUpdate()
                            self.updateFocusIfNeeded()
                        }
                    }
                }
                else {
                    self.pagerVC.update([section])
                }
            }
            callback()
        })
    }
    
    func performFeaturedPlaylistSegue(with playlist: PlaylistModel, and zObject: ZobjectModel, at section: CollectionSection) {
        playlist.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
            if (videos?.count)! > 0 {
                self.selectedVideo = videos!.first!
                self.selectedShow = playlist
                self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: section)
            }
            else {
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                homeVC.playlistParentAsId = zObject.getStringValue("playlistid")
                homeVC.playlistParent = playlist
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        })
        self.secondPress = true
    }
    
    func addPager() {
        guard let playlistParent = self.playlistParent else { return }
        let objects : Array<PlaylistModel> = [playlistParent]
        let items = CollectionContainerVC.categoryValuesToCollectionItems(objects)
        
        for (index,zObject) in objects.enumerated() {
            items[index].imageURL = getPlaylistBannerImageURL(with: zObject)
        }
        
        let section = CollectionSection()
        section.isPager = true
        section.items = items
        section.insets.left = 0
        section.insets.top = 0
        section.insets.bottom = 0
        section.horizontalSpacing = 0.0
        section.cellSize = Const.kCollectionPagerCellSize
        
        if self.pagerVC == nil {
            self.pagerVC = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
            self.pagerVC.view.height = 700.0
            self.pagerVC.isInfinityScrolling = false
            self.collectionVC.addChildViewController(self.pagerVC)
            self.pagerVC.didMove(toParentViewController: self.collectionVC)
            self.pagerVC.configWithSection(section)
        }
        else {
            self.pagerVC.update([section])
        }
    }
    
    func fillSections() {
        var sections = [] as Array<CollectionSection>
        if self.pagerVC != nil {
            let headerSection = CollectionSection()
            headerSection.controller = self.pagerVC
            headerSection.insets = UIEdgeInsetsMake(0, 0, Const.kCollectionPagerVCBottomMargin, 0)
            sections.append(headerSection)
        }
        sections.append(contentsOf: self.getSectionsForShows())
        self.collectionVC.configWithSections(sections)
        if sections.count == 0 && self.pagerVC == nil {
            self.showErrorInfo()
        } else if sections.count == 1 && self.pagerVC != nil {
            //only pager and pager can be empty
            self.showErrorInfo("No videos available")
        }
    }
    
    func getSectionsForShows() -> Array<CollectionSection> {
        var result = [CollectionSection]()
        for value in self.playlists {
            result.append(self.sectionForValue(value))
        }
        return result
    }
    
    func sectionForValue(_ value: PlaylistModel) -> CollectionSection {
        var controllerSection: CollectionSection
        var controller: BaseCollectionVC
        
        if let existedSection = self.collectionVC.sectionForObject(value), existedSection.controller != nil {
            controllerSection = existedSection
            controller = existedSection.controller as! BaseCollectionVC
        } else {
            controllerSection = CollectionSection()
            controller = self.storyboard?.instantiateViewController(withIdentifier: "BaseCollectionVC") as! BaseCollectionVC
        }
        
        if value.playlistItemCount > 0 {
            value.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                var videoItems = CollectionContainerVC.videosToCollectionItems(videos)
                if videoItems.count > HomeVC.kMaxVideosInSection {
                    let lastVideo = videoItems[HomeVC.kMaxVideosInSection] as! VideoCollectionItem
                    videoItems = Array(videoItems[0..<HomeVC.kMaxVideosInSection])
                    videoItems.append(lastVideo.convertToMore())
                }
                let videosSection = CollectionSection()
                videosSection.items = videoItems
                videosSection.object = value
                videosSection.insets.top = 0
                videosSection.insets.bottom = 0
                videosSection.thumbnailLayout = value.thumbnailLayout
                if value.thumbnailLayout == .poster {
                    videosSection.cellSize = Const.kCollectionCellPosterSize
                }
                if(!controller.isConfigurated) {
                    controller.configWithSection(videosSection)
                } else {
                    controller.update([videosSection])
                }
            })
        } else {
            let queryModel = QueryPlaylistsModel()
            queryModel.parentId = value.pId
            ZypeAppleTVBase.sharedInstance.getPlaylists(queryModel, completion: {(playlists: Array<PlaylistModel>?, error: NSError?) in
                if error == nil && playlists != nil {
                    let playlistItems = CollectionContainerVC.categoryValuesToCollectionItems(playlists)
                    let videosSection = CollectionSection()
                    videosSection.items = playlistItems
                    videosSection.object = value
                    videosSection.insets.top = 0
                    videosSection.insets.bottom = 0
                    videosSection.thumbnailLayout = value.thumbnailLayout
                    if value.thumbnailLayout == .poster {
                        videosSection.cellSize = Const.kCollectionCellPosterSize
                    }
                    if !controller.isConfigurated {
                        controller.configWithSection(videosSection)
                    } else {
                        controller.update([videosSection])
                    }
                }
            })
        }
        
        if value.thumbnailLayout == .poster {
            controller.view.height = Const.kCollectionCellPosterSize.height
        } else {
            controller.view.height = Const.kCollectionCellSize.height
        }
        
        if value.playlistItemCount > 0 {//load screen with videos
            controller.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                self.selectedVideo = item.object as! VideoModel
                self.selectedShow = section.object as! PlaylistModel
                self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: section)
            }
        } else {
            controller.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                let selectedPlaylist = item.object as! PlaylistModel
                if selectedPlaylist.playlistItemCount > 0 {
                    
                    //load screen with videos focusing first one
                    self.selectedShow = item.object as! PlaylistModel
                    self.selectedShow.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                        if (videos?.count)! > 0 {
                            self.selectedVideo = videos!.first!
                            self.performSegue(withIdentifier: HomeVC.kShowDetailsSegueID, sender: section)
                        }
                    })
                } else {
                    //load playlist with playlists
                    let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    homeVC.playlistParent = selectedPlaylist
                    homeVC.playlistParentAsId = selectedPlaylist.ID
                    self.navigationController?.pushViewController(homeVC, animated: true)
                }
            }
        }
        
        controllerSection.controller = controller
        controllerSection.title = value.titleString
        controllerSection.object = value
        controllerSection.insets.top = Const.kCollectionSectionHeaderBottomMargin
        controllerSection.insets.bottom = Const.kBaseSectionInsets.bottom
        return controllerSection
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == HomeVC.kShowDetailsSegueID {
            let detailsVC = segue.destination as! ShowDetailsVC
            detailsVC.selectedShow = self.selectedShow
            detailsVC.selectedVideo = self.selectedVideo

            if Const.kNativeTvod {
                detailsVC.fetchVideoEntitlements {
                    super.prepare(for: segue, sender: sender)
                }
            } else {
                super.prepare(for: segue, sender: sender)
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
        super.prepare(for: segue, sender: sender)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = FadeNavigationAnimationController()
        animationController.reverse = operation == .pop
        return animationController
    }
    
    func showErrorInfo(_ description: String? = nil) {
        self.infoView.isHidden = false
        self.collectionWrapperView.isHidden = true
        self.infoLabel.text = description ?? localized("Home.DefaultErrorMessage")
    }
    
    func hideErrorInfo() {
        self.infoView.isHidden = true
        self.collectionWrapperView.isHidden = false
    }
    
    @IBAction func onReload(_ sender: AnyObject) {
        ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.initialize(Const.sdkSettings, loadCategories: false, loadPlaylists: false, completion: {_ in})
        self.hideErrorInfo()
        self.reloadData()
    }
    
}
