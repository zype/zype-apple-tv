//
//  GuideVC.swift
//  DeveloperChallengeAppleTVApp
//
//  Created by Advantiss on 4/16/19.
//

import UIKit
import ZypeAppleTVBase

class GuideVC: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lblCurrentTime: UILabel!
    
    var menuPressRecognizer: UITapGestureRecognizer!
    var focusedIndexPath: IndexPath? = nil
    var selectedIndexPath: IndexPath? = nil
    var timer: Timer? { didSet { oldValue?.invalidate() } }
    
    var guides = [GuideModel]()
    var startDate: Date? = nil
    var dateHeaderView: GuideDateHeader? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(GuideChannelHeader.self, forSupplementaryViewOfKind: "ChannelHeader", withReuseIdentifier: "ChannelHeader")
        self.collectionView.register(GuideChannelBackground.self, forSupplementaryViewOfKind: "ChannelBackground", withReuseIdentifier: "ChannelBackground")
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "ChannelSeparator", withReuseIdentifier: "ChannelSeparator")
        self.collectionView.register(GuideTimeHeader.self, forSupplementaryViewOfKind: "TimeHeader", withReuseIdentifier: "TimeHeader")
        self.collectionView.register(GuideDateHeader.self, forSupplementaryViewOfKind: "DateHeader", withReuseIdentifier: "DateHeader")
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "TimeIndicator", withReuseIdentifier: "TimeIndicator")
        self.collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: "TimeSeparator", withReuseIdentifier: "TimeSeparator")
        
        self.startDate = self.getStartTime()
        menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(self.menuButtonAction(recognizer:)))
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadGuides), name: NSNotification.Name(rawValue: "zype_reload_guide_notification"), object: nil)
        self.loadGuides()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(GuideVC.timerFire), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.timer = nil
    }
    
    @objc func menuButtonAction(recognizer:UITapGestureRecognizer) {
        if let focusedIndexPath = self.focusedIndexPath {
            if !self.guides[focusedIndexPath.section].programs[focusedIndexPath.item].containsDate(Date()) {
                self.focusCurrentTime()
            }
        }
    }
    
    func timerFire() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm aa"
        lblCurrentTime.text = dateFormatter.string(from: Date())
        
        self.collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }) { (success) in
            if self.selectedIndexPath != nil {
                self.focusedIndexPath = self.selectedIndexPath
                self.selectedIndexPath = nil
                self.setNeedsFocusUpdate()
                self.updateFocusIfNeeded()
            }
        }
    }
    
    func getStartTime() -> Date {
        var date = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let calendar = Calendar.current
        
        date = calendar.date(bySetting: .nanosecond, value: 0, of: date)!
        date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        
        for section in 0..<self.guides.count {
            if self.guides[section].programs.count > 0 {
                if date.compare(self.guides[section].programs[0].localStartTime!) == .orderedAscending {
                    date = self.guides[section].programs[0].localStartTime!
                }
            }
        }
        
        return date
    }
    
    func loadGuides() {
        var loadingCount = 0
        self.startDate = self.getStartTime()
        self.guides.removeAll()
        self.collectionView.reloadData()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let fromDate = dateFormatterGet.string(from: self.startDate!)
        let toDate = dateFormatterGet.string(from: Calendar.current.date(byAdding: .day, value: 10, to: self.startDate!)!)
        
        self.activityIndicator.startAnimating()
        ZypeAppleTVBase.sharedInstance.getGuides(50) { (guides, error) in
            if error == nil && guides != nil {
                self.guides = guides!
                for index in 0...(self.guides.count-1) {
                    ZypeAppleTVBase.sharedInstance.getGuidePrograms(self.guides[index].ID,
                                                                    sort: "start_time",
                                                                    order: "asc",
                                                                    greaterThan: fromDate,
                                                                    lessThan: toDate,
                                                                    completion: { (programs, error) in
                        if error == nil && programs != nil {
                            self.guides[index].programs = programs!
                        } else {
                            self.guides[index].programs = [GuideProgramModel]()
                        }
                        loadingCount += 1
                        if loadingCount == self.guides.count {
                            self.didRefreshGuide()
                        }
                    })
                }
            } else {
                self.guides = [GuideModel]()
                self.didRefreshGuide()
            }
        }
    }
    
    func didRefreshGuide() {
        self.guides = self.guides.filter({ (guide) -> Bool in
            return guide.programs.count > 0
        })
        
        self.startDate = self.getStartTime()
        self.activityIndicator.stopAnimating()
        
        self.focusCurrentTime()
    }
    
    func focusCurrentTime() {
        var isFindFocus = false
        for section in 0...(self.guides.count-1) {
            if self.guides[section].programs.count > 0 {
                for item in 0...(self.guides[section].programs.count-1) {
                    if self.guides[section].programs[item].containsDate(Date()) {
                        self.focusedIndexPath = IndexPath(item: item, section: section)
                        isFindFocus = true
                        break
                    }
                }
            }
            if isFindFocus {
                break
            }
        }
        self.collectionView.reloadData()
        if isFindFocus {
            self.collectionView.scrollToItem(at: self.focusedIndexPath!, at: .left, animated: true)
            self.view.removeGestureRecognizer(self.menuPressRecognizer)
        }
    }
}

extension GuideVC: UICollectionViewDataSource, GuideCollectionViewDelegate {
    
    // MARK: - GuideCollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, runtimeForProgramAtIndexPath indexPath: IndexPath) -> Double {
        
        if indexPath.section < self.guides.count {
            if indexPath.item < self.guides[indexPath.section].programs.count {
                let program = self.guides[indexPath.section].programs[indexPath.item]
                return Double(program.duration)
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, startForProgramAtIndexPath indexPath: IndexPath) -> Double {
        
        if indexPath.section < self.guides.count {
            if indexPath.item < self.guides[indexPath.section].programs.count {
                let program = self.guides[indexPath.section].programs[indexPath.item]
                if program.localStartTime != nil {
                    return program.localStartTime!.timeIntervalSince(self.startDate!)
                }
            }
        }
        return 0
    }
    
    func timeIntervalForTimeIndicatorForCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Double {
        return self.startDate != nil ? Date().timeIntervalSince(self.startDate!) : 0
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.guides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guides[section].programs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCell", for: indexPath) as! GuideCell
        let program = self.guides[indexPath.section].programs[indexPath.item]
        cell.lblTitle.text = program.title
        cell.isAiring = program.isAiring
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath)
        
        if kind == "ChannelBackground" {
            if indexPath.item != 0 {
                view.backgroundColor = UIColor(red: 44/255.0, green: 44/255.0, blue: 44/255.0, alpha: 1.0)
            } else {
                view.backgroundColor = UIColor(red: 49/255.0, green: 49/255.0, blue: 49/255.0, alpha: 1.0)
            }
        }
        else if kind == "ChannelHeader" {
            let guide = self.guides[indexPath.section]
            let header = view as! GuideChannelHeader
            
            if guide.name != "" {
                header.imageView.isHidden = true
                header.lblTitle.isHidden = false
                header.lblTitle.text = guide.name
            } else {
                header.imageView.isHidden = false
                header.lblTitle.isHidden = true
                header.imageView?.image = UIImage(named: "LaunchImage")
            }
        }
        else if kind == "ChannelSeparator" {
            view.backgroundColor = UIColor(red: 17/255.0, green: 17/255.0, blue: 17/255.0, alpha: 1.0)
        }
        else if kind == "DateHeader" {
            dateHeaderView = (view as! GuideDateHeader)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM, d"
            
            dateHeaderView!.label?.text = dateFormatter.string(from: Date())
        }
        else if kind == "TimeHeader" {
            let header = view as! GuideTimeHeader
            let date = self.startDate!.addingTimeInterval(Double(1800 * indexPath.item))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.short
            
            header.titleLabel?.text = dateFormatter.string(from: date as Date)
        }
        else if kind == "TimeSeparator" {
            view.backgroundColor = UIColor.lightGray
        }
        else if kind == "TimeIndicator" {
            view.backgroundColor = UIColor.blue
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let program = self.guides[indexPath.section].programs[indexPath.item]
        if program.localStartTime! > Date() {
            errorAlert("We're sorry, that program is not available yet")
            return
        }
        
        if !self.guides[indexPath.section].video_id.isEmpty {
            let queryModel = QueryVideosModel(categoryValue: nil, exceptCategoryValue: nil, playlistId: "", searchString: "", page: 0, perPage: 1)
            queryModel.videoID = self.guides[indexPath.section].video_id
            ZypeAppleTVBase.sharedInstance.getVideos(queryModel) { (videos, error) in
                if error == nil && videos != nil && (videos?.count)! > 0 {
                    self.selectedIndexPath = indexPath
                    if program.isAiring {
                        self.playVideo(videos![0])
                    } else {
                        let startTime = SSUtils.dateToString(program.start_time!, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
                        let endTime = SSUtils.dateToString(program.end_time!, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")
                        
                        self.playVideo(videos![0], playlist: nil, isResuming: false, startTime: startTime, endTime: endTime)
                    }
                } else {
                    print(error?.localizedDescription ?? "Error: Guide Video Play")
                }
            }
        }
    }
    
    //MARK: Focus
    
    override var preferredFocusedView: UIView? {
        get {
            if let focusIndexPath = self.focusedIndexPath {
                return self.collectionView.cellForItem(at: focusIndexPath)
            }
            return nil
        }
    }
    
    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return self.focusedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        if let indexPath = context.nextFocusedIndexPath {
            self.focusedIndexPath = indexPath
            self.view.addGestureRecognizer(self.menuPressRecognizer)
            
            let program = self.guides[self.focusedIndexPath!.section].programs[self.focusedIndexPath!.item]
            if self.dateHeaderView != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM, d"
                self.dateHeaderView?.label.text = dateFormatter.string(from: program.localStartTime!)
            }
        }
        
        return true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //Ensure the leftmost program cell is not cut off when focused
        
        guard let cell = UIScreen.main.focusedView as? UICollectionViewCell,
            let layout = self.collectionView.collectionViewLayout as? GuideCollectionViewLayout
            else { return }
        
        let point = targetContentOffset.pointee
        let leftPadding = CGFloat(layout.channelWidth + layout.padding * 2)
        
        let topPos = cell.frame.minY < point.y ? cell.frame.minY : point.y
        
        if point.x + leftPadding > cell.frame.minX {
            targetContentOffset.pointee = CGPoint(x: cell.frame.minX - leftPadding, y: topPos)
        }
    }
}
