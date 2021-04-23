//
//  PlayerVC.swift
//  UITest
//
//  Created by Eugene Lizhnyk on 10/8/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import ZypeAppleTVBase
import MMSmartStreaming
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

protocol ZypePlayerDelegate: class {
    func segmentAnalyticsPaylod() -> [String: Any]
    func isLivesStream() -> Bool
    func isResumingPlayback() -> Bool
}

class PlayerVC: UIViewController, DVIABPlayerDelegate, ZypePlayerDelegate {
    
    // MARK: - Properties
    var adPlayer: DVIABPlayer?
    var playerLayer = AVPlayerLayer()
    var playerItem: AVPlayerItem!
    var playerController = AVPlayerViewController()
    var playerURL : URL!
    var playerView: DVPlayerView?
    var isSkippable = false
    var isResuming = true
    var isAutoPlay = false
    var isStopped = false
    var timer: Timer?
    var showingInstructionTime = 5
    var instructionLabel: UILabel?
    var playerItemContext = 1
    
    var beacon = ""
    var customDimensions = [String: String]()
    var segmentPayload  = [String: Any]()

    var playlist: Array<VideoModel>? = nil
    var currentVideo: VideoModel!
    var adsData: [adObject] = [adObject]()
    var adTimer: Timer!
    var currentTime: CMTime!
    
    var userDefaults = UserDefaults.standard
    var timeObserverToken: Any?
    var adsArray: NSMutableArray?
    var url: NSURL?
    
    // added for past programs
    var startTime: String? = nil
    var endTime: String? = nil
    
    var completionDelegate: ChangeVideoDelegate? = nil
    
    static let supportedAudioFormats: [String] = [
        "MP3",
        "M4A",
        "WAV",
        "WMA",
        "AIFF",
        "FLAC",
        "AAC",
        "PCM",
        "AC3"
    ]
    
    // MARK: - View Lifecycle
    deinit {
        print("Destroying")
        
        NotificationCenter.default.removeObserver(self)
        if self.adPlayer != nil {
            self.removeAdPlayer()
            self.adPlayer = nil
        }
        if self.playerController.player != nil {
            self.playerController.player?.removeObserver(self, forKeyPath:"rate")
            self.playerController.player?.removeObserver(self, forKeyPath:"timeControlStatus")
            self.playerController.player?.removeObserver(self, forKeyPath:"status")
            self.removeBoundaryTimeObserver()
            self.playerController.player?.pause()
        }
        
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentTime = CMTimeMake(value: 250, timescale: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.play(self.currentVideo)
        if (!self.isAutoPlay){
            SegmentAnalyticsManager.sharedInstance.trackStart(resumedByAd: false, isForUserAction: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsManager.sharedInstance.reset()
        SegmentAnalyticsManager.sharedInstance.reset()
        
        if self.completionDelegate != nil && self.currentVideo != nil {
            self.completionDelegate?.changeFocusVideo(self.currentVideo)
        }
    }

    // MARK: - User Interaction
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        
        //type == .Select
        if let type = presses.first?.type, type == .playPause {
            if self.adPlayer != nil {
                
            }
            if #available(tvOS 10.0, *) {
                if let player = self.playerController.player, player.timeControlStatus == .paused{
                    SegmentAnalyticsManager.sharedInstance.trackResume()
                }
            }
        }
            
        else if let type = presses.first?.type, type == .select {
            if self.adPlayer != nil {
                if self.isSkippable == true {
                    if let viewWithTag = self.view.viewWithTag(1001) {
                        viewWithTag.removeFromSuperview()
                    }
                    self.nextAdPlayer()
                }
            }
        }
            
        else if let type = presses.first?.type, type == .menu {
            if !currentVideo.onAir {
                let timeStamp = self.playerController.player?.currentTime().seconds
                if timeStamp > 30.0 {
                    userDefaults.setValue(timeStamp, forKey: "\(currentVideo.getId())")
                }
            }
            
            NotificationCenter.default.removeObserver(self)
            if self.adPlayer != nil {
                self.adPlayer?.pause()
            }
            if self.playerController.player != nil {
                self.isStopped = true
                self.playerController.player?.pause()
                AnalyticsManager.sharedInstance.trackStop()
            }
            self.removePeriodicTimeObserver()
        }
        
        // Call this for all unhandled key presses
        super.pressesBegan(presses, with: event)
    }
    
    // MARK: - Video Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate", context == &playerItemContext {
            if let player = self.playerController.player, player.rate == 0 {
                if self.isAutoPlay {
                    self.showInstructionView()
                }
            }
            return
        }else if keyPath == "timeControlStatus", context == &playerItemContext {
            if #available(tvOS 10.0, *) {
                if let player = self.playerController.player, player.timeControlStatus == .paused, self.isStopped != true{
                    SegmentAnalyticsManager.sharedInstance.trackPause()
                }
            }
            return
        }else if keyPath == "status", context == &playerItemContext {
            if let player = self.playerController.player, player.status == .failed{
                SegmentAnalyticsManager.sharedInstance.trackError()
            }
            return
        }
        if self.adPlayer!.status == .readyToPlay {
            if self.adPlayer?.contentPlayerItem.currentTime().seconds < 0.5 && self.adPlayer?.contentPlayerItem.currentTime().seconds > 0.0 {
                self.removeAdPlayer()
                self.setupVideoPlayer()
            }
            else {
                DispatchQueue.main.async(execute: {
                    self.adPlayer!.play()
                })
            }
        }
        else if self.adPlayer!.status == .failed {
            self.removeAdPlayer()
            self.setupVideoPlayer()
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    func addBoundaryTimeObserver(duration: CMTime) {
        
        // Divide the asset's duration into quarters.
        let interval = CMTimeMultiplyByFloat64(duration, multiplier: 0.25)
        var currentTime = CMTime.zero
        var timesInCMTime = [CMTime]()
        var times = [NSValue]()
        
        // Calculate boundary times
        while currentTime < duration {
            currentTime = currentTime + interval
            timesInCMTime.append(currentTime)
            times.append(NSValue(time:currentTime))
        }
        
        timeObserverToken = self.playerController.player?.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            [weak self] in
            
            if let playerTime = self?.playerController.player?.currentTime(){
                let currentSeconds = playerTime.seconds
                if Int(timesInCMTime[0].seconds) == Int(currentSeconds){
                    SegmentAnalyticsManager.sharedInstance.trackIntermediatePoints(point: .PlayerContentCompleted25Percent)
                }else if Int(timesInCMTime[1].seconds) == Int(currentSeconds){
                    SegmentAnalyticsManager.sharedInstance.trackIntermediatePoints(point: .PlayerContentCompleted50Percent)
                }else if Int(timesInCMTime[2].seconds) == Int(currentSeconds){
                    SegmentAnalyticsManager.sharedInstance.trackIntermediatePoints(point: .PlayerContentCompleted75Percent)
                }
            }
        }
    }
    
    func removeBoundaryTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            self.playerController.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func play(_ model: VideoModel) {
        model.getVideoObject(.kVimeoHls, completion: {[unowned self] (playerObject: VideoObjectModel?, error: NSError?) in
            if let _ = playerObject, let videoURL = playerObject?.videoURL, var url = NSURL(string: videoURL), error == nil {
                
                if let startTime = self.startTime, let endTime = self.endTime {
                    guard let newUrl = NSURL(string: "\(videoURL)&start=\(startTime)&end=\(endTime)") else {
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    url = newUrl
                }
                
                self.currentVideo = model
                if self.validateEntitlement(for: playerObject) {
                    let adsArray = self.getAdsFromResponse(playerObject)
                    self.playerURL = url as URL
                    self.adsArray = adsArray
                    self.url = url

                    let analyticsInfo = self.getAnalyticsFromResponse(playerObject)
                    self.beacon = analyticsInfo.beacon
                    self.customDimensions = analyticsInfo.customDimensions
                    self.segmentPayload =  self.getSegmentAnalyticsFromResponse(playerObject)

                    if adsArray.count > 0 && self.adsData.last?.offset == 0 { // check for preroll
                        self.playAds(adsArray: adsArray, url: url)
                        _ = self.adsData.popLast()
                    }
                    else {
                        self.setupVideoPlayer()
                    }
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                self.navigationController?.popViewController(animated: true)
                displayError(error)
            }
        })
    }
    
    fileprivate func validateEntitlement(for playerObject: VideoObjectModel?) -> Bool {
        if (playerObject?.json?["message"]) != nil {
//            let alert = UIAlertController(title: "Error", message: responseMessage as? String, preferredStyle: .alert)
//            let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: { (_) in
//                self.dismiss(animated: true, completion: nil)
//            })
//            alert.addAction(confirmAction)
//            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func showInstructionView() {
        if instructionLabel == nil {
            instructionLabel = UILabel()
            instructionLabel?.x = 90
            instructionLabel?.width = self.playerController.view.frame.width - 180
            instructionLabel?.height = 50
            instructionLabel?.y = self.playerController.view.frame.height - 150
            
            instructionLabel?.textAlignment = .center
            instructionLabel?.textColor = UIColor.white
            
            instructionLabel?.text = String(format: "Press the Menu button to exit and return to the Home screen.")
        }
        instructionLabel?.removeFromSuperview()
        
        self.view.addSubview(instructionLabel!)
        if self.timer != nil, self.timer!.isValid {
            self.timer?.invalidate()
            self.timer = nil
        }
        self.showingInstructionTime = 5
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateInstructionView), userInfo: nil, repeats: true)
    }
    
    @objc func updateInstructionView() {
        self.showingInstructionTime -= 1
        if self.showingInstructionTime == 0 {
            self.timer?.invalidate()
            self.timer = nil
            self.instructionLabel?.removeFromSuperview()
        }
    }
    
    func setupVideoPlayer() {
        if let viewWithTag = self.view.viewWithTag(1001) {
            viewWithTag.removeFromSuperview()
        }
        if let viewWithTag = self.view.viewWithTag(1002) {
            viewWithTag.removeFromSuperview()
        }
        
        let player = ZypeAVPlayer(url: self.playerURL)
        player.delegate = self
        self.playerController.player = player
        self.addChild(self.playerController)
        self.view.addSubview(self.playerController.view)
        self.playerController.view.frame = self.view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        player.addObserver(self, forKeyPath: "rate", options: [], context: &playerItemContext)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [], context: &playerItemContext)
        player.addObserver(self, forKeyPath: "status", options: [], context: &playerItemContext)
        
        
        
        if self.adsData.count > 0 {
            self.observeTimerForMidrollAds()
        }
        
        if isResuming {
            if !currentVideo.onAir {
                if let timeStamp = userDefaults.object(forKey: "\(currentVideo.getId())") {
                    let time = CMTimeMakeWithSeconds(timeStamp as! Float64, preferredTimescale: 1)
                    player.seek(to: time)
                }
            }
        }

        if !self.beacon.isEmpty && !self.customDimensions.isEmpty {
            if let url = URL(string: self.beacon) {
                AnalyticsManager.sharedInstance.trackPlayer(withConfigUrl: url, withPlayer: player, withCustomData: self.customDimensions)
            }
        }

		if Const.Advanced_Analytics_Enabled == true{
            self.integrateAdvancedAnalyticsSDKWithAssetURL(urlString: self.playerURL.absoluteString)
        }

        player.play()
        
        if !self.isLivesStream(){
            let duration = CMTime(seconds: Double(self.currentVideo?.durationValue ?? 0), preferredTimescale: 1)
            self.addBoundaryTimeObserver(duration: duration)
        }
        
        if self.isAutoPlay {
            self.showInstructionView()
            SegmentAnalyticsManager.sharedInstance.trackAutoPlay()
        }
        
        if player.currentItem?.asset.tracks.count == 1 {
            self.addThumbnailToPlayer()
        }
    }
    
    func isAudioContent(url: String) -> Bool {
        let format = url.components(separatedBy: "/").last?.components(separatedBy: ".").last ?? ""
        return PlayerVC.supportedAudioFormats.contains(format.uppercased())
    }
    
    func addThumbnailToPlayer(){
        guard self.playerController.player != nil else { return }
        guard let videoUrl = url?.absoluteString else { return }
        guard isAudioContent(url: videoUrl) else { return }
        
        var squareThumbnailFound: Bool = false
        currentVideo.images.forEach {
            if $0.name == "square_thumbnail",
               let url = NSURL(string: $0.imageURL) {
                let imageView = URLImageView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height))
                imageView.contentMode = .scaleAspectFit
                imageView.configWithURL(url as URL, nil)
                self.playerController.contentOverlayView?.addSubview(imageView)
                squareThumbnailFound = true
            }
        }
        
        if !squareThumbnailFound {
            currentVideo.thumbnails.forEach {
                if CGFloat($0.height) == view.height,
                   CGFloat($0.width) == view.width,
                   let url = NSURL(string: $0.imageURL) {
                    let imageView = URLImageView(frame: CGRect(x: 0, y: 0, width: $0.width, height: $0.height))
                    imageView.contentMode = .scaleAspectFit
                    imageView.configWithURL(url as URL, nil)
                    self.playerController.contentOverlayView?.addSubview(imageView)
                    squareThumbnailFound = true
                }
            }
        }
    }
    
    private func integrateAdvancedAnalyticsSDKWithAssetURL(urlString: String) {
        AVPlayerIntegrationWrapper.shared.enableLogTrace(logStTrace: true)
        let assetInfo = MMAssetInformation(assetURL: urlString, assetID:
            "", assetName: self.currentVideo.videoTitle, videoId: self.currentVideo.videoId)
        assetInfo.addCustomKVP("siteId", Const.kSiteId)
        if (Const.kNativeSubscriptionEnabled == true && ZypeAppleTVBase.sharedInstance.consumer?.subscriptionIds != nil && ZypeAppleTVBase.sharedInstance.consumer?.subscriptionIds.count > 0){
            assetInfo.addCustomKVP("subscriptionId", ZypeAppleTVBase.sharedInstance.consumer?.subscriptionIds[0] as? String ?? "")
        }else{
            assetInfo.addCustomKVP("subscriptionId", "")
        }
        let registrationInfo = MMRegistrationInformation(customerID: Const.Advanced_Analytics_CustomerID, playerName: "tvos_player")
        AVPlayerIntegrationWrapper.initializeAssetForPlayer(assetInfo: assetInfo, registrationInformation: registrationInfo, player: self.playerController.player)
    }
    
    @objc func resumePlayingFromAds() {
        self.removeAdPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(PlayerVC.contentDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerController.player?.currentItem)
        
        if let player = self.playerController.player {
            player.play()
        }
        else {
            setupVideoPlayer()
        }
    }
    
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        // Make sure we don't call contentComplete as a result of an ad completing.
        if (self.playerController.player?.currentItem != nil) && ((notification.object as! AVPlayerItem) == self.playerController.player!.currentItem) {
            userDefaults.removeObject(forKey: self.currentVideo.getId())
            
            self.playerController.removeFromParent()
            self.playerController.view.removeFromSuperview()
            self.playerController.player?.replaceCurrentItem(with: nil)
            self.playerController = AVPlayerViewController()
            
            self.isStopped = true
            AnalyticsManager.sharedInstance.trackStop()
            SegmentAnalyticsManager.sharedInstance.trackComplete()
            
            AVPlayerIntegrationWrapper.cleanUp()

            if let _ = self.playlist,
                let currentVideoIndex = self.playlist?.firstIndex(of: self.currentVideo), self.playlist?.count > 0 {
                
                if currentVideoIndex + 1 < self.playlist!.count {
                    let nextVideo = self.playlist![currentVideoIndex + 1]
                    self.play(nextVideo)
                }
                else {
                    self.play(self.playlist!.first!)
                }
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - DVIABPlayerDelegate
    func player(_ player: DVIABPlayer!, shouldPauseForAdBreak playBreak: DVVideoPlayBreak!) -> Bool {
        return true
    }
    
    func player(_ player: DVIABPlayer!, didFail playBreak:DVVideoPlayBreak!, withError:Error ) {
        print("did fail playback")
    }
    
    func segmentAnalyticsPaylod() -> [String: Any] {
        return segmentPayload
    }

    func isLivesStream() -> Bool {
        return self.currentVideo.onAir
    }
    
    func isResumingPlayback() -> Bool {
        return isResuming
    }
}

class ZypeAVPlayer: AVPlayer {
    weak var delegate: ZypePlayerDelegate?

    func resumePlay() {
        super.play()
        SegmentAnalyticsManager.sharedInstance.trackStart(resumedByAd: true)
    }
    
    override func play() {
        super.play()
        if let delegate = delegate {
            SegmentAnalyticsManager.sharedInstance.setConfigurations(self, delegate.segmentAnalyticsPaylod(), delegate.isLivesStream(), delegate.isResumingPlayback())
        }
        SegmentAnalyticsManager.sharedInstance.trackStart(resumedByAd: false)
    }
    
    override func pause() {
        super.pause()
    }
    
    override func seek(to time: CMTime) {
        super.seek(to: time)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
    
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
    
    override func seek(to date: Date) {
        super.seek(to: date)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
    
    override func seek(to time: CMTime, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: time, completionHandler: completionHandler)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
    
    override func seek(to date: Date, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: date, completionHandler: completionHandler)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
    
    override func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        super.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
        SegmentAnalyticsManager.sharedInstance.trackSeek()
    }
}
