//
//  BaseCollectionVC.swift
//  Zype
//
//  Created by Eugene Lizhnyk on 10/12/15.
//  Copyright © 2015 Eugene Lizhnyk. All rights reserved.
//

import UIKit
import ZypeAppleTVBase

enum CollectionSectionHeaderStyle {
  case Regular
  case Centered
}

class CollectionLabeledItem: NSObject {
  
  static let kImageObservableKey = "imageURL"
  static let kTitleObservableKey = "title"
  
  dynamic var title: String! = ""
  dynamic var imageURL: NSURL!
  var imageName: String!
  var object: BaseModel!
  
  func loadResources(){}
  
}

class CollectionSection: NSObject {
  
  var title: String! = ""
  var items: Array<CollectionLabeledItem>! = []
  var controller: UIViewController! {
    didSet {
      self.insets = UIEdgeInsetsZero
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
  var headerStyle: CollectionSectionHeaderStyle = .Regular
  
  override init() {
    super.init()
  }
  
  init(controller: UIViewController) {
    super.init()
    self.controller = controller
  }
  
  func itemIndex(item: CollectionLabeledItem) -> Int {
    var index = 0
    for _item in self.items {
      if((_item.object != nil && item.object != nil && item.object == _item.object) || item == _item) {
        return index
      }
      index++
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
  static let autoscrollInterval: NSTimeInterval = 4.0
  
  private var isHorizontal: Bool = false {
    didSet {
      let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
      layout.scrollDirection = self.isHorizontal ? .Horizontal : .Vertical
    }
  }
  
  var isInfinityScrolling = false
  var sections: Array<CollectionSection>! = []
  var itemFocusedCallback: ((item: CollectionLabeledItem, section: CollectionSection) -> Void)!
  var itemSelectedCallback: ((item: CollectionLabeledItem, section: CollectionSection) -> Void)!
  var prepareForReuseCallback: (() -> Void)!
  var isConfigurated: Bool = false
  var lastFocusedItemIndexPath: NSIndexPath!
  var lastSelectedItemIndexPath: NSIndexPath!
  var timer: NSTimer!
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  deinit {
    self.itemFocusedCallback = nil
    self.itemSelectedCallback = nil
    self.prepareForReuseCallback = nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.activityIndicator.transform = CGAffineTransformMakeScale(3, 3)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if(self.isInfinityScrolling) {
      self.timer = NSTimer.scheduledTimerWithTimeInterval(BaseCollectionVC.autoscrollInterval, target: self, selector: "scrollToNextItem", userInfo: nil, repeats: true)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    if(self.timer != nil) {
      self.timer.invalidate()
    }
  }
  
  func configWithSections(sections: Array<CollectionSection>) {
    self.sections = sections
    self.collectionView?.reloadData()
    self.activityIndicator.stopAnimating()
    self.isConfigurated = true
  }
  
  func configWithSection(section: CollectionSection) -> CollectionSection {
    self.isHorizontal = true
    self.collectionView?.clipsToBounds = false
    self.configWithSections([section])
    if(self.isInfinityScrolling) {
      self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: BaseCollectionVC.maxCellIndex / 2, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
    }
    return section
  }
  
  func scrollToNextItem() {
    if(self.focusedCell() == nil) {
      if let paths = self.collectionView?.indexPathsForVisibleItems() {
        let sorted = paths.sort({(path1, path2) in
          return path1.row < path2.row
        })
        if(sorted.count > 1) {
          let nextIndex = sorted[1].row + 1 < BaseCollectionVC.maxCellIndex ? sorted[1].row + 1 : BaseCollectionVC.maxCellIndex / 2
          self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forRow: nextIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: true)
        }
      }
    }
  }
  
  func focusedCell() -> UICollectionViewCell? {
    if let allCells = self.collectionView?.visibleCells() {
      for cell in allCells {
        if(cell.focused) {
          return cell
        }
      }
    }
    for controller in self.childViewControllers {
      if(controller.isKindOfClass(BaseCollectionVC)) {
        if let vc = controller as? BaseCollectionVC,
          let cell = vc.focusedCell() {
            return cell
        }
      }
    }
    return nil
  }
  
  func update(newSections: Array<CollectionSection>){
    var toInsert = [NSIndexPath]()
    var toDelete = [NSIndexPath]()
    var index = 0
    for newSection in newSections {
      let oldSection = self.sections[index]
      for item in oldSection.items {
        let foundIndex = newSection.itemIndex(item)
        if(foundIndex == NSNotFound) {
          toDelete.append(NSIndexPath(forRow: oldSection.itemIndex(item), inSection: index))
        }
      }
      for item in newSection.items {
        if(oldSection.itemIndex(item) == NSNotFound) {
          toInsert.append(NSIndexPath(forRow: newSection.itemIndex(item), inSection: index))
        }
      }
      index++
    }
    
    self.sections = newSections
    self.collectionView?.performBatchUpdates({[unowned self] in
      self.collectionView?.insertItemsAtIndexPaths(toInsert)
      self.collectionView?.deleteItemsAtIndexPaths(toDelete)
      self.reloadHeaders()
      }, completion: nil)
  }
  
  func reloadHeaders() {
    for (index) in 0 ..< self.sections.count {
      let indexPath = NSIndexPath(forRow: 0, inSection: index)
      if let header = self.collectionView?.supplementaryViewForElementKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath) as? HeaderCell {
        self.configHeader(header, indexPath: indexPath)
      }
    }
  }
  
  func configHeader(header: HeaderCell, indexPath: NSIndexPath) {
    header.label.text = self.sections[indexPath.section].title
    header.style = self.sections[indexPath.section].headerStyle
  }
  
  func prepareForReuse(){
    if(self.prepareForReuseCallback != nil) {
      self.prepareForReuseCallback()
    }
  }
  
  func sectionForObject(object: BaseModel) -> CollectionSection? {
    for section in self.sections {
      if section.object != nil && section.object! == object {
        return section
      }
    }
    return nil
  }
  
}


extension BaseCollectionVC {
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return self.sections.count
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if(self.isInfinityScrolling && self.sections[section].items.count > 0) {
      return BaseCollectionVC.maxCellIndex
    }
    return self.sections[section].controller == nil ? self.sections[section].items.count : 1
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let section = self.sections[indexPath.section]
    if(section.controller != nil) {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ControllerCell", forIndexPath: indexPath) as! ControllerCell
      cell.config(section.controller)
      if(section.controller.isKindOfClass(BaseCollectionVC)) {
        let reusableController = section.controller as! BaseCollectionVC
        reusableController.prepareForReuse()
      }
      return cell
    }
    
    let data = self.sections[indexPath.section].items[self.isInfinityScrolling ? (indexPath.row % self.sections[indexPath.section].items.count) : indexPath.row]
    var result: UICollectionViewCell
    if(!section.isPager) {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
      cell.configWithItem(data)
      result = cell
    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PagerCell", forIndexPath: indexPath) as! PagerCell
      if let _ = data.imageName {
        cell.configWithImageName(data.imageName!)
      } else {
        cell.configWithURL(data.imageURL)
      }
      result = cell
    }
    data.loadResources()
    return result
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as! HeaderCell
    self.configHeader(header, indexPath: indexPath)
    return header
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.lastSelectedItemIndexPath = indexPath
    if(self.itemSelectedCallback != nil){
      let section = self.sections[indexPath.section]
      self.itemSelectedCallback(item: section.items[self.isInfinityScrolling ? (indexPath.row % section.items.count) : indexPath.row], section: section)
    }
  }
  
  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return self.sections[indexPath.section].controller == nil
  }
  
  override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    self.lastFocusedItemIndexPath = context.nextFocusedIndexPath
    if(self.itemFocusedCallback != nil){
      let indexPath = context.nextFocusedIndexPath
      if(indexPath != nil && self.sections[indexPath!.section].items.count > 0){
        let section = self.sections[indexPath!.section]
        self.itemFocusedCallback(item: section.items[self.isInfinityScrolling ? (indexPath!.row % section.items.count) : indexPath!.row], section: section)
      }
    }
  }
  
  override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool{
    return self.sections[indexPath.section].controller == nil
  }
  
  func sectionForIndexPath(path: NSIndexPath?) -> CollectionSection? {
    if(path != nil && self.sections.count > path?.section) {
      return self.sections[path!.section]
    }
    return nil
  }
  
  func itemForIndexPath(path: NSIndexPath?) -> CollectionLabeledItem? {
    if let section = self.sectionForIndexPath(path) {
      if(section.items.count > path!.row) {
        return section.items[path!.row]
      }
    }
    return nil
  }
  
  func indexOfSection(section: CollectionSection) -> Int{
    if let index = self.sections.indexOf(section) {
      return index
    }
    return NSNotFound
  }
  
  func sectionForItem(item: CollectionLabeledItem?) -> CollectionSection? {
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
  
  func indexPathForItem(item: CollectionLabeledItem?) -> NSIndexPath? {
    if (item != nil) {
      if let section = self.sectionForItem(item) {
        let sectionIndex = self.indexOfSection(section)
        if(sectionIndex != NSNotFound) {
          return NSIndexPath(forRow: section.itemIndex(item!), inSection: sectionIndex)
        }
      }
    }
    return nil
  }
  
}


extension BaseCollectionVC : UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let section = self.sections[indexPath.section]
    if(section.controller != nil) {
      return CGSize(width: self.view.width, height: section.controller.view.height)
    }
    return section.cellSize
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return self.sections[section].insets
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return self.sections[section].horizontalSpacing
  }
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return self.sections[section].verticalSpacing
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if(self.sections[section].title.isEmpty) {
      return CGSizeZero
    } else {
      return CGSize(width: self.view.width, height: Const.kCollectionSectionHeaderHeight)
    }
  }
  
}