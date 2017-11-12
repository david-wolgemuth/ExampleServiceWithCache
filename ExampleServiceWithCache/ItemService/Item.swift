//
//  Item.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

enum ItemType: String {
    case typeA
    case typeB
    case typeC
}

struct Item {
    
    let id: Int
    var type: ItemType
    var title: String?
    var description: String?
    
    func fancyString() -> String {
        if title == nil && description == nil {
            return type.rawValue
        }
        if description == nil {
            return title!
        }
        if title == nil {
            return description!
        }
        return "\(title!)\(id) - \(description!)"
    }
}
