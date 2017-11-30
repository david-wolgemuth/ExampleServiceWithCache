//
//  ItemCache.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import Foundation

typealias CachedItemFetchedCallback = (_ err: String?, _ item: Item?) -> ()

class CachedItem {
    
    var itemId: Int
    
    init(itemId: Int) {
        self.itemId = itemId
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil, queue: .main) { [weak self] notification in
            print("LOW MEMORY WARNING :: DUMPING CACHE")
            self?.dumpItem(err: "Memory Warning")
        }
    }
    func fetch(callback: @escaping CachedItemFetchedCallback) {
        self.cachedItemFetchedCallbacks.append(callback)
        if let _ = completedFetch, let _ = self.item {
            // Already in cache
            callAllCallbacks()
            return
        }
        if let _ = beganFetch {
            // delegate has already made request .. shouldn't start another
            return
        }
        beganFetch = Date()
        
        fakeHttpRequest(id: self.itemId) { (success) in
            self.handleHttpResponse(success: success)
        }
    }
    
    private var item: Item?
    private var beganFetch: Date?
    private var completedFetch: Date?
    private var failedFetch: Date?
    private var cachedItemFetchedCallbacks = [CachedItemFetchedCallback]()
    
    private func callAllCallbacks(err: String?=nil) {
        DispatchQueue.main.async {
            for callback in self.cachedItemFetchedCallbacks {
                callback(err, self.item)
            }
            self.cachedItemFetchedCallbacks = []
        }
    }
    
    private func handleHttpResponse(success: Bool) {
        if !success {
            beganFetch = nil  // allows request to be reattempted
            failedFetch = Date()
            callAllCallbacks(err: "Something Bad Happened")
            return
        }
        completedFetch = Date()
        let item = Item(id: self.itemId, type: .typeA, title: "Blah", description: "Bob Lah Blah's Law Blog")
        self.item = item
        callAllCallbacks()
    }
    
    private func dumpItem(err: String) {
        self.item = nil
        beganFetch = nil  // allows request to be reattempted
        failedFetch = Date()
        callAllCallbacks(err: err)
    }
}

func fakeHttpRequest(id: Int, completion: @escaping (Bool) -> ()) {
    // https://stackoverflow.com/a/40169565/4637643
    let delay = Double(arc4random_uniform(6))  // random amount of time up to 6 seconds
    DispatchQueue.global(qos: .default)
        .asyncAfter(deadline: .now() + delay) {
            
        let badRequest = (arc4random_uniform(4) == 0) // randomly trigger a bad request
        completion(!badRequest)
    }
}
