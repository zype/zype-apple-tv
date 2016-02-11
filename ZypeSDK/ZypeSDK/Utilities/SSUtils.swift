//
//  SSUtils.swift
//  UIKitCatalog
//
//  Created by Ilya Sorokin on 10/8/15.
//  Copyright © 2015 Apple. All rights reserved.
//

import UIKit

enum UtilError: ErrorType {
    case InvalidArgument
}

internal let kApiDateFromeStringFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
internal let kApiDateToStringFormat = "yyyy-MM-dd"

class SSUtils {
    
    static func dateToString(date: NSDate?, format: String = kApiDateToStringFormat) -> String
    {
        if date == nil
        {
            return ""
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        let dateString: String = dateFormatter.stringFromDate(date!)
        return dateString
    }
    
    static func stringToDate(string: String, format: String = kApiDateFromeStringFormat) -> NSDate?
    {
        if string.isEmpty
        {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.dateFromString(string)
    }
    
    static func stringFromDictionary(dic: Dictionary<String, AnyObject>?, key: String) throws -> String
    {
        if (dic == nil)
        {
            throw UtilError.InvalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.InvalidArgument
        }
        if ((value as? String) == nil)
        {
             throw UtilError.InvalidArgument
        }
        return value as! String
    }
    
    static func intagerFromDictionary(dic: Dictionary<String, AnyObject>?, key: String) throws -> Int
    {
        if (dic == nil)
        {
            throw UtilError.InvalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.InvalidArgument
        }
        if ((value as? Int) == nil)
        {
            throw UtilError.InvalidArgument
        }
        return value as! Int
    }

    static func doubleFromDictionary(dic: Dictionary<String, AnyObject>?, key: String) throws -> Double
    {
        if (dic == nil)
        {
            throw UtilError.InvalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.InvalidArgument
        }
        if ((value as? Double) == nil)
        {
            throw UtilError.InvalidArgument
        }
        return value as! Double
    }
    
    static func boolFromDictionary(dic: Dictionary<String, AnyObject>?, key: String) throws -> Bool
    {
        if (dic == nil)
        {
            throw UtilError.InvalidArgument
        }
        let value = dic![key]
        if (value == nil)
        {
            throw UtilError.InvalidArgument
        }
        if ((value as? Bool) == nil)
        {
            throw UtilError.InvalidArgument
        }
        return value as! Bool
    }

    static func categoryToId(categoryKey: String, categoryValue: String) -> String
    {
        let categoryId = escapedString(categoryKey + categoryValue)
        return categoryId
    }
    
    //TODO refactoring remove stringByReplacingOccurrencesOfString
    static func escapedString(string: String) -> String
    {
        let value = string.stringByAddingPercentEncodingWithAllowedCharacters(.URLPathAllowedCharacterSet())
        return value!.stringByReplacingOccurrencesOfString("&", withString: "%26")
    }
    
}
