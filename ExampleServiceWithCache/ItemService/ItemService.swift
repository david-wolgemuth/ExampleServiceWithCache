//
//  ItemService.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation


class ItemService {
    
    static let shared = ItemService()  // Singleton
    
    func fetch(itemId: Int, callback: @escaping CachedItemFetchedCallback) {
        if let cachedItem = items[itemId] {
            cachedItem.fetch(callback: callback)
            return
        }
        let cachedItem = CachedItem(itemId: itemId)
        self.items[itemId] = cachedItem
        cachedItem.fetch(callback: callback)
    }
    
    private var items = [Int: CachedItem]()
    
    private init() {}
}
