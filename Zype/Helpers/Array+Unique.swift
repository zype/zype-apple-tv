//
//  Array+Unique.swift
//  AndreySandbox
//
//  Created by Александр on 13.10.2017.
//  Copyright © 2017 Eugene Lizhnyk. All rights reserved.
//

import Foundation

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}
