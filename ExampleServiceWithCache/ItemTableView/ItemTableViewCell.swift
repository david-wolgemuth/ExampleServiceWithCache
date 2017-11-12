//
//  ItemTableViewCell.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    var itemId: Int?
    
    func setItem(withId id: Int) {
        if itemId == id {
            return  // request already made, waiting on response
        }
        updateLabels(text: "\(id)", detail: nil)
        itemId = id
        ItemService.shared.fetch(self, itemId: id)
    }
    
    private func updateLabels(text: String?, detail: String?) {
        textLabel?.text = text
        detailTextLabel?.text = detail
        setNeedsLayout()
        layoutIfNeeded()
    }
}

extension ItemTableViewCell: ItemServiceObserverTarget {
    
    func itemService(_ itemService: ItemService, didFetch item: Item) {
        if itemId != item.id {
            return  // reusable cell no longer being used for this item
        }
        updateLabels(text: "\(item.id)", detail: item.fancyString())
    }
    func itemService(_ itemService: ItemService, failedToFetch itemId: Int) {
        if itemId != itemId {
            return  // reusable cell no longer being used for this item
        }
        updateLabels(text: "\(itemId)", detail: "FAILED TO FETCH \(itemId)")
    }
}
