//
//  BaseCollectionVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/12/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase
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


enum CollectionSectionHeaderStyle {
    case regular
    case centered
}

enum CollectionLockStyle {
    case empty
    case locked
    case unlocked
}

class CollectionLabeledItem: NSObject {
    
    static let kImageObservableKey = "imageURL"
    static let kTitleObservableKey = "title"
    static let kLockObservableKey = "lock"
    
    dynamic var title: String! = ""
    dynamic var imageURL: URL!
    dynamic var posterURL: URL!
    var imageName: String!
    var object: BaseModel!
    var lockStyle: CollectionLockStyle?
    
    func loadResources(){}
    
}

class CollectionSection: NSObject {
    
    var title: String! = ""
    var items: Array<CollectionLabeledItem>! = []
    var controller: UIViewController! {
        didSet {
            self.insets = UIEdgeInsets.zero
            self.verticalSpacing = 0
            self.horizontalSpacing = 0
        }
    }
    var object: BaseModel?
    var insets: UIEdgeInsets = Const.kBaseSectionInsets
    var verticalSpacing: CGFloat = Const.kCollectionVerticalSpacing
    var horizontalSpacing: CGFloat = Const.kCollectionHorizontalSpacing
    var cellSize: CGSize = Const.kCollectionCellSize
    var isPager: Bool = false
    var headerStyle: CollectionSectionHeaderStyle = .regular
    var lockStyle: CollectionLockStyle = .empty
    var thumbnailLayout: LayoutOrientation! = .landscape
    
    override init() {
        super.init()
    }
    
    init(controller: UIViewController) {
        super.init()
        self.controller = controller
    }
    
    func itemIndex(_ item: CollectionLabeledItem) -> Int {
        var index = 0
        for _item in self.items {
            if((_item.object != nil && item.object != nil && item.object == _item.object) || item == _item) {
                return index
            }
            index += 1
        }
        return NSNotFound
    }
    
    func allObjects() -> Array<AnyObject> {
        var result = [AnyObject]()
        for item in self.items {
            result.append(item.object)
        }
        return result
    }
    
}


class BaseCollectionVC: UICollectionViewController {
    
    static let maxCellIndex: Int = 5000
    static let autoscrollInterval: TimeInterval = 4.0
    
    fileprivate var isHorizontal: Bool = false {
        didSet {
            let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
            layout.scrollDirection = self.isHorizontal ? .horizontal : .vertical
        }
    }
    
    var isInfinityScrolling = false
    var sections: Array<CollectionSection>! = []
    var itemFocusedCallback: ((_ item: CollectionLabeledItem, _ section: CollectionSection) -> Void)!
    var itemSelectedCallback: ((_ item: CollectionLabeledItem, _ section: CollectionSection) -> Void)!
    var prepareForReuseCallback: (() -> Void)!
    var isConfigurated: Bool = false
    var lastFocusedItemIndexPath: IndexPath!
    var lastSelectedItemIndexPath: IndexPath!
    var timer: Timer!
    var manualFocusIndexPath: IndexPath?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    deinit {
        self.itemFocusedCallback = nil
        self.itemSelectedCallback = nil
        self.prepareForReuseCallback = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        if #available(tvOS 11, *) {
            self.collectionView?.contentInsetAdjustmentBehavior = .never
        }
        self.collectionView?.remembersLastFocusedIndexPath = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isInfinityScrolling {
            self.timer = Timer.scheduledTimer(timeInterval: BaseCollectionVC.autoscrollInterval, target: self, selector: #selector(BaseCollectionVC.scrollToNextItem), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.timer != nil {
            self.timer.invalidate()
        }
    }
    
    func configWithSections(_ sections: Array<CollectionSection>) {
        self.sections = sections
        self.collectionView?.reloadData()
        self.activityIndicator.stopAnimating()
        self.isConfigurated = true
    }
    
    @discardableResult func configWithSection(_ section: CollectionSection) -> CollectionSection {
        self.isHorizontal = true
        self.collectionView?.clipsToBounds = false
        self.configWithSections([section])
        return section
    }
    
    @objc func scrollToNextItem() {
        if self.focusedCell() == nil {
            if let paths = self.collectionView?.indexPathsForVisibleItems {
                let sorted = paths.sorted(by: {(path1, path2) in
                    return path1.row < path2.row
                })
                if(sorted.count > 1) {
                    let nextIndex = sorted[1].row + 1 < BaseCollectionVC.maxCellIndex ? sorted[1].row + 1 : BaseCollectionVC.maxCellIndex / 2
                    self.collectionView?.scrollToItem(at: IndexPath(row: nextIndex, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
        }
    }
    
    func focusedCell() -> UICollectionViewCell? {
        if let allCells = self.collectionView?.visibleCells {
            for cell in allCells {
                if(cell.isFocused) {
                    return cell
                }
            }
        }
        for controller in self.children {
            if(controller.isKind(of: BaseCollectionVC.self)) {
                if let vc = controller as? BaseCollectionVC,
                    let cell = vc.focusedCell() {
                    return cell
                }
            }
        }
        return nil
    }
    
    func update(_ newSections: Array<CollectionSection>){
        var toInsert = [IndexPath]()
        var toDelete = [IndexPath]()
        var index = 0
        for newSection in newSections {
            let oldSection = self.sections[index]
            for item in oldSection.items {
                let foundIndex = newSection.itemIndex(item)
                if(foundIndex == NSNotFound) {
                    toDelete.append(IndexPath(row: oldSection.itemIndex(item), section: index))
                }
            }
            for item in newSection.items {
                if(oldSection.itemIndex(item) == NSNotFound) {
                    toInsert.append(IndexPath(row: newSection.itemIndex(item), section: index))
                }
            }
            index += 1
        }
        
        self.sections = newSections
        self.collectionView?.performBatchUpdates({[unowned self] in
            self.collectionView?.insertItems(at: toInsert)
            self.collectionView?.deleteItems(at: toDelete)
            self.reloadHeaders()
            }, completion: nil)
    }
    
    func reloadHeaders() {
        for index in 0 ..< self.sections.count {
            let indexPath = IndexPath(row: 0, section: index)
            if let header = self.collectionView?.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? HeaderCell {
                self.configHeader(header, indexPath: indexPath)
            }
        }
    }
    
    func configHeader(_ header: HeaderCell, indexPath: IndexPath) {
        header.label.text = self.sections[indexPath.section].title
        header.style = self.sections[indexPath.section].headerStyle
    }
    
    func prepareForReuse(){
        if self.prepareForReuseCallback != nil {
            self.prepareForReuseCallback()
        }
    }
    
    func sectionForObject(_ object: BaseModel) -> CollectionSection? {
        for section in self.sections {
            if section.object != nil && section.object! == object {
                return section
            }
        }
        return nil
    }
    
}


extension BaseCollectionVC {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.sections.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isInfinityScrolling && self.sections[section].items.count > 0 {
            return BaseCollectionVC.maxCellIndex
        }
        return self.sections[section].controller == nil ? self.sections[section].items.count : 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.sections[indexPath.section]
        
        if section.controller != nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ControllerCell", for: indexPath) as! ControllerCell
            cell.config(section.controller)
            if section.controller.isKind(of: BaseCollectionVC.self) {
                let reusableController = section.controller as! BaseCollectionVC
                reusableController.prepareForReuse()
            }
            return cell
        }
        //check for index out of bounds when data is being fetched after signout
        if section.items?.count == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: (section.isPager ? "PagerCell" :"ImageCell"), for: indexPath)
        }
        
        let data = section.items[self.isInfinityScrolling ? (indexPath.row % self.sections[indexPath.section].items.count) : indexPath.row]
        
        var result: UICollectionViewCell
        if !section.isPager {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.configWithItem(data, orientation: section.thumbnailLayout)
            result = cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagerCell", for: indexPath) as! PagerCell
            if let _ = data.imageName {
                cell.configWithImageName(data.imageName!)
            }
            else {
                cell.configWithURL(data.imageURL)
            }
            result = cell
        }
        data.loadResources()
        return result
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! HeaderCell
        self.configHeader(header, indexPath: indexPath)
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.lastSelectedItemIndexPath = indexPath
        if(self.itemSelectedCallback != nil){
            let section = self.sections[indexPath.section]
            self.itemSelectedCallback(section.items[self.isInfinityScrolling ? (indexPath.row % section.items.count) : indexPath.row], section)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return self.sections[indexPath.section].controller == nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        
        if let nextView = context.nextFocusedView, let prevView = context.previouslyFocusedView {
            if prevView.isKind(of: PagerCell.self),  !nextView.isKind(of: PagerCell.self), let nextIndexPath = context.nextFocusedIndexPath {
                manualFocusIndexPath = IndexPath(item: 0, section: nextIndexPath.section)
                self.setNeedsFocusUpdate()
                return false
            }
        }
        
        return true
    }
    
    override func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return manualFocusIndexPath
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.lastFocusedItemIndexPath = context.nextFocusedIndexPath
        if(self.itemFocusedCallback != nil){
            let indexPath = context.nextFocusedIndexPath
            if(indexPath != nil && self.sections[indexPath!.section].items.count > 0){
                let section = self.sections[indexPath!.section]
                self.itemFocusedCallback(section.items[self.isInfinityScrolling ? (indexPath!.row % section.items.count) : indexPath!.row], section)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool{
        return self.sections[indexPath.section].controller == nil
    }
    
    func sectionForIndexPath(_ path: IndexPath?) -> CollectionSection? {
        if(path != nil && self.sections.count > path?.section) {
            return self.sections[path!.section]
        }
        return nil
    }
    
    func itemForIndexPath(_ path: IndexPath?) -> CollectionLabeledItem? {
        if let section = self.sectionForIndexPath(path) {
            if(section.items.count > path!.row) {
                return section.items[path!.row]
            }
        }
        return nil
    }
    
    func indexOfSection(_ section: CollectionSection) -> Int{
        if let index = self.sections.index(of: section) {
            return index
        }
        return NSNotFound
    }
    
    func sectionForItem(_ item: CollectionLabeledItem?) -> CollectionSection? {
        if (item != nil) {
            for section in self.sections {
                let index = section.itemIndex(item!)
                if(index != NSNotFound){
                    return section
                }
            }
        }
        return nil
    }
    
    func indexPathForItem(_ item: CollectionLabeledItem?) -> IndexPath? {
        if (item != nil) {
            if let section = self.sectionForItem(item) {
                let sectionIndex = self.indexOfSection(section)
                if(sectionIndex != NSNotFound) {
                    return IndexPath(row: section.itemIndex(item!), section: sectionIndex)
                }
            }
        }
        return nil
    }
    
}


extension BaseCollectionVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = self.sections[indexPath.section]
        if(section.controller != nil) {
            if(Const.kInlineTitleTextDisplay) {
                if (self.sections.count == (indexPath.section + 1)) {
                    return CGSize(width: self.view.width, height: section.controller.view.height + 50)
                }
                return CGSize(width: self.view.width, height: section.controller.view.height + 20)
            }
            return CGSize(width: self.view.width, height: section.controller.view.height)
        }
        return section.cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sections[section].insets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.sections[section].horizontalSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.sections[section].verticalSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if(self.sections[section].title.isEmpty) {
            return CGSize.zero
        } else {
            return CGSize(width: self.view.width, height: Const.kCollectionSectionHeaderHeight)
        }
    }
    
}
