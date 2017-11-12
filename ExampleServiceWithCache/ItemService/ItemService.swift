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

class ItemService {
    
    static let shared = ItemService()  // Singleton
    
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
    
    private var items = [Int: CachedItem]()
    private var observers = [ItemServiceObserver]()
    
    private init() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] notification in
            print("LOW MEMORY WARNING :: DUMPING CACHE")
            self?.dumpCache()
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

extension ItemService: CachedItemDelegate {
    
    func cachedItem(_ cachedItem: CachedItem, didFetch item: Item) {
        let itemObservers = popObservers(ofItem: item.id)
        DispatchQueue.main.async {
            for observer in itemObservers {
                observer.target?.itemService(self, didFetch: item)
            }
        }
    }
    func cachedItem(_ cachedItem: CachedItem, failedToFetch itemId: Int) {
        let itemObservers = popObservers(ofItem: itemId)
        DispatchQueue.main.async {
            for observer in itemObservers {
                observer.target?.itemService(self, failedToFetch: itemId)
            }
        }
    }
    private func popObservers(ofItem itemId: Int) -> [ItemServiceObserver] {
        let itemObservers = observers.filter({ (observer) -> Bool in
            return observer.itemId == itemId
        })
        self.observers = observers.filter({ (observer) -> Bool in
            return observer.itemId != itemId
        })
        return itemObservers
    }
}
