//
//  ItemService.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

protocol ItemServiceObserverTarget: class {
    func itemService(_ itemService: ItemService, didFetch item: Item)
    func itemService(_ itemService: ItemService, failedToFetch itemId: Int)
}

class ItemService: CachedItemDelegate {
    
    static let shared = ItemService()  // Singleton
    
    private var items = [Int: CachedItem]()
    private var observers = [ItemServiceObserver]()
    
    private init() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] notification in
            print("LOW MEMORY WARNING :: DUMPING CACHE")
            self?.dumpCache()
        }
    }
    
    func fetch(_ target: ItemServiceObserverTarget, itemId: Int) {
        let wrappedObserver = ItemServiceObserver(itemId: itemId, target: target)
        observers.append(wrappedObserver)
        
        if let cachedItem = items[itemId] {
            cachedItem.fetch()
            return
        }
        let cachedItem = CachedItem(delegate: self, itemId: itemId)
        self.items[itemId] = cachedItem
        cachedItem.fetch()
    }
    
    func cachedItem(_ cachedItem: CachedItem, didFetch item: Item) {
        var index = 0
        while index < observers.count {
            let observer = observers[index]
            if observer.itemId != item.id {
                index += 1
                continue
            }
            DispatchQueue.main.async {
                observer.target?.itemService(self, didFetch: item)
            }
            observers.remove(at: index)
        }
    }
    
    func cachedItem(_ cachedItem: CachedItem, failedToFetch itemId: Int) {
        var index = 0
        while index < observers.count {
            let observer = observers[index]
            if observer.itemId != itemId {
                index += 1
                continue
            }
            DispatchQueue.main.async {
                observer.target?.itemService(self, failedToFetch: itemId)
            }
            observers.remove(at: index)
        }
    }
    
    private func dumpCache() {
        items.removeAll()
        DispatchQueue.main.async {
            for observer in self.observers {
                observer.target?.itemService(self, failedToFetch: observer.itemId)
            }
        }
        observers.removeAll()
    }
    
    private struct ItemServiceObserver {
        let itemId: Int
        weak var target: ItemServiceObserverTarget?
    }
}
