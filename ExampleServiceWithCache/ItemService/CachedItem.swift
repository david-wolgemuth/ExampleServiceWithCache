//
//  ItemCache.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

protocol CachedItemDelegate: class {
    func cachedItem(_ cachedItem: CachedItem, didFetch item: Item)
    func cachedItem(_ cachedItem: CachedItem, failedToFetch itemId: Int)
}

class CachedItem {
    
    var itemId: Int
    
    init(delegate: CachedItemDelegate, itemId: Int) {
        self.itemId = itemId
        self.delegate = delegate
    }
    func fetch() {
        if let _ = completedFetch, let item = self.item {
            // Already in cache
            delegate?.cachedItem(self, didFetch: item)
            return
        }
        if let _ = beganFetch {
            // delegate has already made request .. shouldn't start another
            return
        }
        beganFetch = Date()
        
        // simulating an async http request
        DispatchQueue.global(qos: .default).async {
            let badRequest = (arc4random_uniform(4) == 0) // randomly trigger a bad request
            self.handleHttpResponse(badRequest: badRequest)
        }
    }
    
    private var item: Item?
    private var beganFetch: Date?
    private var completedFetch: Date?
    private var failedFetch: Date?
    private weak var delegate: CachedItemDelegate?
    
    private func handleHttpResponse(badRequest: Bool) {
        if badRequest {
            beganFetch = nil  // allows request to be reattempted
            failedFetch = Date()
            delegate?.cachedItem(self, failedToFetch: itemId)
            return
        }
        completedFetch = Date()
        let item = Item(id: self.itemId, type: .typeA, title: "Blah", description: "Bob Lah Blah's Law Blog")
        delegate?.cachedItem(self, didFetch: item)
        self.item = item
    }
}
