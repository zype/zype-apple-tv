//
//  GuideCollectionViewLayout.swift
//
//  Created by Advantiss
//

import UIKit

public protocol GuideCollectionViewDelegate : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, runtimeForProgramAtIndexPath indexPath: IndexPath) -> Double
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, startForProgramAtIndexPath indexPath: IndexPath) -> Double
    
    func timeIntervalForTimeIndicatorForCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> Double
}

open class GuideCollectionViewLayout : UICollectionViewLayout {
    
    var hourWidth = 1000.0
    var padding = 6.0
    var rowHeight = 140.0
    var expandHeight = 230.0
    var timesHeight = 90.0
    var channelWidth = 200.0
    var indicatorHeight = 4.0
    
    fileprivate var frames : Array<Array<CGRect>> = []
    fileprivate var channelHeaderFrames : Array<CGRect> = []
    fileprivate var timeHeaderFrames : Array<CGRect> = []
    fileprivate var timeIndicatorFrame : CGRect = CGRect.zero
    
    open override func prepare() {
        
        guard let collectionView = self.collectionView, let delegate = collectionView.delegate as? GuideCollectionViewDelegate else { return }
        
        var currentY = self.padding
        
        self.frames = Array<Array<CGRect>>()
        self.channelHeaderFrames = Array<CGRect>()
        self.timeHeaderFrames = Array<CGRect>()
        
        for section in 0 ..< collectionView.numberOfSections {
            var currentX = self.padding * 2
            var prevLastX = self.padding * 2
            
            var sectionFrames = Array<CGRect>()
            let sectionItems = collectionView.numberOfItems(inSection: section)
            for item in 0 ..< sectionItems {
                let runtime = delegate.collectionView(collectionView, layout: self, runtimeForProgramAtIndexPath: IndexPath(item: item, section: section))
                let startX = delegate.collectionView(collectionView, layout: self, startForProgramAtIndexPath: IndexPath(item: item, section: section))
                let width = self.hourWidth * runtime / 3600.0
                currentX = self.padding * 2 + self.hourWidth * startX / 3600.0
                
                var cellWidth = width - self.padding
                if currentX < prevLastX {
                    let diff = prevLastX - currentX
                    currentX = prevLastX
                    cellWidth = cellWidth - diff
                    sectionFrames.append(CGRect(x: currentX + self.padding * 0.5, y: currentY, width: max(0, cellWidth), height: self.rowHeight))
                } else {
                    sectionFrames.append(CGRect(x: currentX + self.padding * 0.5, y: currentY, width: max(0, cellWidth), height: self.rowHeight))
                }
                prevLastX = currentX + cellWidth + self.padding
            }
            
            self.frames.append(sectionFrames)
            self.channelHeaderFrames.append(CGRect(x: 0, y: currentY, width: self.channelWidth, height: self.rowHeight))
            
            if let frame = self.channelHeaderFrames.last {
                currentY = Double(frame.maxY) + self.padding
            }
        }
        
        if (collectionView.numberOfSections > 0) {
            var currentX = self.padding * 2
            while (currentX < Double(self.collectionViewContentSize.width)) {
                self.timeHeaderFrames.append(CGRect(x: CGFloat(currentX), y: CGFloat(0.0), width: CGFloat(self.hourWidth * 0.5), height: CGFloat(self.timesHeight)))
                currentX = Double(self.timeHeaderFrames.last!.maxX)
            }
        }
        
        if (channelHeaderFrames.count > 0) {
            let timeInterval = delegate.timeIntervalForTimeIndicatorForCollectionView(collectionView, layout: self)
            let indicatorWidth = CGFloat(self.padding * 2 + ((self.hourWidth) * timeInterval / 3600.0))
            self.timeIndicatorFrame = CGRect(x: 0, y: CGFloat(self.timesHeight), width: indicatorWidth, height: CGFloat(self.indicatorHeight))
//            self.timeIndicatorFrame = CGRect(x: indicatorWidth, y: CGFloat(-self.timesHeight), width: CGFloat(4.0), height: CGFloat(0.0))
        }
        
        collectionView.contentInset.top = CGFloat(self.timesHeight)
        collectionView.contentInset.left = CGFloat(self.channelWidth)
    }
    
    open override var collectionViewContentSize : CGSize {
        var maxX = 0.0, maxY = 0.0
        
        for sectionFrames in self.frames {
            guard let frame = sectionFrames.last else { continue }
            maxX = max(maxX, Double(frame.maxX))
            maxY = max(maxY, Double(frame.maxY))
        }
        
        return CGSize(width: maxX + self.padding * 2, height: maxY + self.padding * 2)
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = self.collectionView else { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        if elementKind == "ChannelHeader" {
            attributes.frame = self.channelHeaderFrames[indexPath.section]
            attributes.zIndex = 3
            attributes.frame.origin.x = collectionView.contentOffset.x
        }
        else if elementKind == "ChannelSeparator" {
            attributes.frame = CGRect(x: collectionView.contentOffset.x + CGFloat(self.channelWidth),
                                      y: collectionView.contentOffset.y,
                                      width: CGFloat(self.padding),
                                      height: collectionView.frame.size.height)
            attributes.zIndex = 9
        }
        else if elementKind == "DateHeader" {
            attributes.frame = CGRect(x: 0, y: 0, width: self.channelWidth, height: self.timesHeight)
            attributes.zIndex = 8
            attributes.frame.origin.x = collectionView.contentOffset.x
            attributes.frame.origin.y = collectionView.contentOffset.y
        }
        else if elementKind == "TimeHeader" {
            attributes.frame = self.timeHeaderFrames[indexPath.item]
            attributes.zIndex = 5
            attributes.frame.origin.y = collectionView.contentOffset.y
        }
        else if elementKind == "TimeSeparator" {
            attributes.frame = CGRect(x: 0,
                                      y: collectionView.contentOffset.y + CGFloat(self.timesHeight - self.indicatorHeight),
                                      width: CGFloat(self.timeHeaderFrames.count) * CGFloat(self.hourWidth),
                                      height: CGFloat(self.indicatorHeight))
            attributes.frame.origin.y = collectionView.contentOffset.y + CGFloat(self.timesHeight - self.indicatorHeight)
            attributes.zIndex = 6
        }
        else if elementKind == "TimeIndicator" {
            attributes.frame = self.timeIndicatorFrame
            attributes.frame.origin.y = collectionView.contentOffset.y + CGFloat(self.timesHeight - self.indicatorHeight)
            attributes.zIndex = 7
        }
        else if elementKind == "ChannelBackground" {
            if indexPath.item == 0 {
                attributes.frame = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + CGFloat(self.timesHeight), width: CGFloat(self.channelWidth), height: collectionView.frame.size.height - CGFloat(self.timesHeight))
                attributes.zIndex = 2
            }
            else {
                attributes.frame = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.frame.size.width, height: CGFloat(self.timesHeight))
                attributes.zIndex = 4
            }
        }
        
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = self.frames[indexPath.section][indexPath.item]
        attributes.alpha = 1.0
        attributes.zIndex = 1
        return attributes
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        
        var array = Array<UICollectionViewLayoutAttributes>()
        if collectionView.numberOfSections > 0 {
            if let a = layoutAttributesForSupplementaryView(ofKind: "DateHeader", at: IndexPath(item: 0, section: 0)) { array.append(a) }
            if let a = layoutAttributesForSupplementaryView(ofKind: "ChannelSeparator", at: IndexPath(item: 0, section: 0)) { array.append(a) }
            if let a = layoutAttributesForSupplementaryView(ofKind: "TimeSeparator", at: IndexPath(item: 0, section: 0)) { array.append(a) }
            if let a = layoutAttributesForSupplementaryView(ofKind: "TimeIndicator", at: IndexPath(item: 0, section: 0)) { array.append(a) }
            if let a = layoutAttributesForSupplementaryView(ofKind: "ChannelBackground", at: IndexPath(item: 0, section: 0)) { array.append(a) }
            if let a = layoutAttributesForSupplementaryView(ofKind: "ChannelBackground", at: IndexPath(item: 1, section: 0)) { array.append(a) }
        }
        
        array += self.timeHeaderFrames.enumerated().flatMap { i, frame in
            return layoutAttributesForSupplementaryView(ofKind: "TimeHeader", at: IndexPath(item: i, section: 0))
        }
        
        for section in 0 ..< collectionView.numberOfSections {
            array.append(layoutAttributesForSupplementaryView(ofKind: "ChannelHeader", at: IndexPath(item: 0, section: section))!)
            
            for item in 0 ..< collectionView.numberOfItems(inSection: section) {
                guard let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section)) else { continue }
                
                if attributes.frame.isEmpty == false && rect.intersects(attributes.frame) {
                    array.append(attributes)
                }
            }
        }
        return array
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
