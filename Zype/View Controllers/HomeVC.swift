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
    //static let kPlaylistRootId = "58248a8e77fdb30e22005f39"
    
    @IBOutlet weak var collectionWrapperView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoLabel: StyledLabel!
    @IBOutlet weak var reloadButton: UIButton!
    
    static let kMaxVideosInSection = 20
    
    var pagerVC: BaseCollectionVC!
    var selectedVideo: VideoModel!
    var selectedShow: PlaylistModel!
    var playlists = [PlaylistModel]()
    var playlistParent: PlaylistModel?
    var playlistParentAsId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.reloadButton.setTitle(localized("Home.ReloadButton"), forState: .Normal)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadCollection), name: kZypeReloadScreenNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "ready_to_load_playlists", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
        
        let favorites = NSUserDefaults.standardUserDefaults().arrayForKey(kFavoritesKey) as? Array<String> ?? [String]()
        print(favorites.count)
    }
    
    func reloadCollection() {
        self.collectionVC.isConfigurated = false
 
        for section in self.collectionVC.sections {
            section.controller = nil
        }
    }
    
    
    func playlistByID(ID: String) -> PlaylistModel? {
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
        if(self.playlistParent != nil){
            queryModel.parentId = self.playlistParent!.pId
        } else {
            if(self.playlistParentAsId != nil){
                queryModel.parentId = self.playlistParentAsId!
            } else {
                let rootPlaylistId = NSUserDefaults.standardUserDefaults().objectForKey("root_playlist_id")
                if (rootPlaylistId != nil) {
                     queryModel.parentId = (rootPlaylistId as? String)!
                } else {
                   // self.showErrorInfo("Booooooo. Can't find root_playlist_id in tvOS zObject. Please add it in the platform and relaunch the app.")
                    //return
                    
                    queryModel.parentId = ""
                }
            }
            
        }
        
        ZypeAppleTVBase.sharedInstance.getPlaylists(queryModel, completion: {[unowned self] (playlists: Array<PlaylistModel>?, error: NSError?) in
            if(error == nil && playlists != nil) {
                self.playlists = playlists!
                self.getLivestreamItem({(result: CollectionLabeledItem?) in
                    self.getFeaturedVideos(result, callback: {[unowned self] in
                        self.fillSections()
                        })
                })
                
            } else {
                self.fillSections()
                self.showErrorInfo(error?.localizedDescription)
            }
            })
        
    }
    
    func getLivestreamItem(callback: (result: CollectionLabeledItem?)->()) {
        let queryModel = QueryVideosModel()
        queryModel.onAir = true
        queryModel.sort = "published_at"
        queryModel.ascending = false
        ZypeAppleTVBase.sharedInstance.getVideos(queryModel, completion: {(videos: Array<VideoModel>?, error: NSError?) in
            if let _ = videos where videos!.count > 0 {
                let video = videos!.first!
                let item = CollectionLabeledItem()
                item.object = video
                item.imageName = "on_air"
                // callback(result: item)
                callback(result: nil) //ignore on_air banner for Havoc
            } else {
                callback(result: nil)
            }
        })
    }
    
    func playlistForZObject(object: ZobjectModel) -> PlaylistModel? {
        let playlistID = object.getStringValue("playlistid")
        if let show = self.playlistByID(playlistID) {
            return show
        }
        return nil
    }
    
    func getFeaturedVideos(livestreamItem: CollectionLabeledItem?, callback: () -> Void) {
        
        if(self.playlistParentAsId == nil) {//use only for Home Screen
            
            let type = QueryZobjectsModel()
            type.zobjectType = "top_playlists"
            ZypeAppleTVBase.sharedInstance.getZobjects(type, completion: {(objects: Array<ZobjectModel>?, error: NSError?) in
                if let _ = objects where objects!.count > 0 {
                    var items = CollectionContainerVC.featuresToCollectionItems(objects)
                    if let _ = livestreamItem {
                        items.insert(livestreamItem!, atIndex: items.count / 2)
                    }
                    let section = CollectionSection()
                    section.isPager = true
                    section.items = items
                    section.insets.top = 0
                    section.insets.bottom = 0
                    section.horizontalSpacing = Const.kCollectionPagerHorizontalSpacing
                    //section.cellSize = Const.kCollectionPagerCellSize
                    section.cellSize = CGSize(width: 1740, height: 700)//490 //original iamge is 1450 x 630 //1920
                    
                    if(self.pagerVC == nil) {
                        self.pagerVC = self.storyboard?.instantiateViewControllerWithIdentifier("BaseCollectionVC") as! BaseCollectionVC
                        self.pagerVC.view.height = 700
                        self.pagerVC.isInfinityScrolling = true
                        self.collectionVC.addChildViewController(self.pagerVC)
                        self.pagerVC.didMoveToParentViewController(self.collectionVC)
                        self.pagerVC.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                            
                            if(item.object.isKindOfClass(VideoModel)) {
                                self.playVideo(item.object as! VideoModel)
                                return
                            }
                            let zObject = (item as! PagerCollectionItem).object as! ZobjectModel
                            if let playlist = self.playlistForZObject(zObject) {
                                playlist.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                                    if(videos?.count > 0) {
                                        self.selectedVideo = videos!.first!
                                        self.selectedShow = playlist
                                        self.performSegueWithIdentifier(HomeVC.kShowDetailsSegueID, sender: section)
                                    } else {//load playlist with playlists
                                        let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
                                        let selectedPlaylist = item.object as! PlaylistModel
                                        homeVC.playlistParent = selectedPlaylist
                                        self.navigationController?.pushViewController(homeVC, animated: true)
                                    }
                                })
                            } else {
                                //load playlist that is not on the screen with playlists
                                let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
                                homeVC.playlistParentAsId = zObject.getStringValue("playlistid")
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }
                        }
                        self.pagerVC.configWithSection(section)
                    } else {
                        self.pagerVC.update([section])
                    }
                }
                
                callback()
            }) } else {//configure header for child playlists
            self.addPager()
            callback()
        }
        
        
    }
    
    func addPager(){
        let objects : Array<PlaylistModel> = []
        let items = CollectionContainerVC.categoryValuesToCollectionItems(objects)
        
        /*for (index,zObject) in objects.enumerate() {
         for picture in zObject.pictures {
         if picture.titleString == "banner"{
         items[index].imageURL = NSURL(string:picture.url)
         }
         }
         }*/
        
        let section = CollectionSection()
        section.isPager = true
        section.items = items
        section.insets.left = 0
        section.insets.top = 0
        section.insets.bottom = 0
        section.horizontalSpacing = 0.0
        section.cellSize = CGSize(width: 1920, height: 70)//820  //490 //original iamge is 1450 x 630 //
        1920
        
        
        if(self.pagerVC == nil) {
            self.pagerVC = self.storyboard?.instantiateViewControllerWithIdentifier("BaseCollectionVC") as! BaseCollectionVC
            self.pagerVC.view.height = 70.0
            self.pagerVC.isInfinityScrolling = false
            self.collectionVC.addChildViewController(self.pagerVC)
            self.pagerVC.didMoveToParentViewController(self.collectionVC)
            self.pagerVC.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                
            }
            self.pagerVC.configWithSection(section)
        } else {
            self.pagerVC.update([section])
        }
    }
    
    func fillSections(){
        var sections = [] as Array<CollectionSection>
        if(self.pagerVC != nil) {
            let headerSection = CollectionSection()
            headerSection.controller = self.pagerVC
            headerSection.insets = UIEdgeInsetsMake(0, 0, Const.kCollectionPagerVCBottomMargin, 0)
            sections.append(headerSection)
        }
        sections.appendContentsOf(self.getSectionsForShows())
        self.collectionVC.configWithSections(sections)
        if(sections.count == 0 && self.pagerVC == nil) {
            self.showErrorInfo()
        }
    }
    
    func getSectionsForShows() -> Array<CollectionSection> {
        var result = [CollectionSection]()
        for value in self.playlists {
            result.append(self.sectionForValue(value))
        }
        return result
    }
    
    func sectionForValue(value: PlaylistModel) -> CollectionSection {
        var controllerSection: CollectionSection
        var controller: BaseCollectionVC
        
        if let existedSection = self.collectionVC.sectionForObject(value) where existedSection.controller != nil {
            controllerSection = existedSection
            controller = existedSection.controller as! BaseCollectionVC
        } else {
            controllerSection = CollectionSection()
            controller = self.storyboard?.instantiateViewControllerWithIdentifier("BaseCollectionVC") as! BaseCollectionVC
        }
        
        if (value.playlistItemCount > 0) {
            value.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                var videoItems = CollectionContainerVC.videosToCollectionItems(videos)
                if(videoItems.count > HomeVC.kMaxVideosInSection) {
                    let lastVideo = videoItems[HomeVC.kMaxVideosInSection] as! VideoCollectionItem
                    videoItems = Array(videoItems[0..<HomeVC.kMaxVideosInSection])
                    videoItems.append(lastVideo.convertToMore())
                }
                let videosSection = CollectionSection()
                videosSection.items = videoItems
                videosSection.object = value
                videosSection.insets.top = 0
                videosSection.insets.bottom = 0
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
                if(error == nil && playlists != nil) {
                    let playlistItems = CollectionContainerVC.categoryValuesToCollectionItems(playlists)
                    let videosSection = CollectionSection()
                    videosSection.items = playlistItems
                    videosSection.object = value
                    videosSection.insets.top = 0
                    videosSection.insets.bottom = 0
                    if(!controller.isConfigurated) {
                        controller.configWithSection(videosSection)
                    } else {
                        controller.update([videosSection])
                    }
                } else {
                    
                }
            })
        }
        
        controller.view.height = Const.kCollectionCellSize.height
        
        if (value.playlistItemCount > 0) {//load screen with videos
            controller.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                self.selectedVideo = item.object as! VideoModel
                self.selectedShow = section.object as! PlaylistModel
                self.performSegueWithIdentifier(HomeVC.kShowDetailsSegueID, sender: section)
            }
        } else {
            controller.itemSelectedCallback = {[unowned self] (item: CollectionLabeledItem, section: CollectionSection) in
                let selectedPlaylist = item.object as! PlaylistModel
                if (selectedPlaylist.playlistItemCount > 0){
                    //load screen with videos focusing first one
                    
                    self.selectedShow = item.object as! PlaylistModel
                    self.selectedShow.getVideos(completion: {(videos: Array<VideoModel>?, error: NSError?) -> Void in
                        if(videos?.count > 0) {
                            self.selectedVideo = videos!.first!
                            self.performSegueWithIdentifier(HomeVC.kShowDetailsSegueID, sender: section)
                        }
                    })
                    
                } else {
                    //load playlist with playlists
                    let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeVC") as! HomeVC
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == HomeVC.kShowDetailsSegueID) {
            let detailsVC = segue.destinationViewController as! ShowDetailsVC
            detailsVC.selectedShow = self.selectedShow
            detailsVC.selectedVideo = self.selectedVideo
        }
        super.prepareForSegue(segue, sender: sender)
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = FadeNavigationAnimationController()
        animationController.reverse = operation == .Pop
        return animationController
    }
    
    func showErrorInfo(description: String? = nil) {
        self.infoView.hidden = false
        self.collectionWrapperView.hidden = true
        self.infoLabel.text = description ?? localized("Home.DefaultErrorMessage")
    }
    
    func hideErrorInfo() {
        self.infoView.hidden = true
        self.collectionWrapperView.hidden = false
    }
    
    @IBAction func onReload(sender: AnyObject) {
        ZypeAppleTVBase.sharedInstance.reset()
        ZypeAppleTVBase.sharedInstance.initialize(Const.sdkSettings, loadCategories: false, loadPlaylists: false, completion: {_ in})
        self.hideErrorInfo()
        self.reloadData()
    }
    
 }
 
