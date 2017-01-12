//
//  UIView+Positioning.swift
//
//  Created by Shai Mishali on 1/19/15.
//  Copyright (c) 2015 Shai Mishali. All rights reserved.
//

import UIKit

extension UIView{
    // MARK: - Basic Properties
    var x:CGFloat{
        set{ self.frame = CGRect(x: _pixelIntegral(newValue), y: self.y, width: self.width, height: self.height) }
        get{ return self.frame.origin.x }
    }
    
    var y:CGFloat{
        set { self.frame = CGRect(x: self.x, y: _pixelIntegral(newValue), width: self.width, height: self.height) }
        get { return self.frame.origin.y }
    }
    
    var width: CGFloat{
        set { self.frame = CGRect(x: self.x, y: self.y, width: _pixelIntegral(newValue), height: self.height) }
        get { return self.frame.size.width }
    }
    
    var height: CGFloat{
        set { self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: _pixelIntegral(newValue)) }
        get { return self.frame.size.height }
    }
    
    // MARK: - Origin and Size
    var origin: CGPoint{
        set { self.frame = CGRect(x: _pixelIntegral(newValue.x), y: _pixelIntegral(newValue.y), width: self.width, height: self.height) }
        get { return self.frame.origin }
    }
    
    var size: CGSize{
        set { self.frame = CGRect(x: self.x, y: self.y, width: _pixelIntegral(newValue.width), height: _pixelIntegral(newValue.height)) }
        get { return self.frame.size }
    }
    
    // MARK: - Extra Properties
    var right: CGFloat{
        set { self.x = newValue - self.width }
        get { return self.x + self.width }
    }
    
    var bottom: CGFloat{
        set { self.y = newValue - self.height }
        get { return self.y + self.height }
    }
    
    var top: CGFloat {
        set { self.y = newValue }
        get { return self.y }
    }
    
    var left: CGFloat {
        set { self.x = newValue }
        get { return self.x }
    }
    
    var centerX: CGFloat{
        set { self.center = CGPoint(x: newValue, y: self.centerY) }
        get { return self.center.x }
    }
    
    var centerY: CGFloat {
        set { self.center = CGPoint(x: self.centerX, y: newValue) }
        get { return self.center.y }
    }
    
    var lastSubviewOnX:UIView?{
        get {
            var outView:UIView = self.subviews[0] as UIView
            
            for v in self.subviews as [UIView] {
                if(v.x > outView.x){ outView = v }
            }
            
            return outView
        }
    }
    
    var lastSubviewOnY:UIView?{
        get {
            var outView:UIView = self.subviews[0] as UIView
            
            for v in self.subviews as [UIView] {
                if(v.y > outView.y){ outView = v }
            }
            
            return outView
        }
    }
    
    // MARK: - Bounds Methods
    var boundsX:CGFloat{
        set{ self.bounds = CGRect(x: _pixelIntegral(newValue), y: self.boundsY, width: self.boundsWidth, height: self.boundsHeight) }
        get{ return self.bounds.origin.x }
    }
    
    var boundsY:CGFloat{
        set { self.frame = CGRect(x: self.boundsX, y: _pixelIntegral(newValue), width: self.boundsWidth, height: self.boundsHeight) }
        get { return self.bounds.origin.y }
    }
    
    var boundsWidth: CGFloat{
        set { self.frame = CGRect(x: self.boundsX, y: self.boundsY, width: _pixelIntegral(newValue), height: self.boundsHeight) }
        get { return self.bounds.size.width }
    }
    
    var boundsHeight: CGFloat{
        set { self.frame = CGRect(x: self.boundsX, y: self.boundsY, width: self.boundsWidth, height: _pixelIntegral(newValue)) }
        get { return self.bounds.size.height }
    }
    
    // MARK: - Private Methods
    fileprivate func _pixelIntegral(_ pointValue:CGFloat) -> CGFloat{
        let scale   = UIScreen.main.scale
        return (round(pointValue * scale) / scale)
    }
}
