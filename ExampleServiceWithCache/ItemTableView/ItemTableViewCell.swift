//
//  ItemTableViewCell.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    static func dequeued(from tableView: UITableView, for indexPath: IndexPath) -> ItemTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
    }
    
    var itemId: Int?
    
    func setItem(withId id: Int) {
        if itemId == id {
            return  // has already been told to set item
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
            return  // cell no longer being used for this item
        }
        updateLabels(text: "\(item.id)", detail: item.fancyString())
    }
    func itemService(_ itemService: ItemService, failedToFetch itemId: Int) {
        if itemId != itemId {
            return  // cell no longer being used for this item
        }
        updateLabels(text: "\(itemId)", detail: "FAILED TO FETCH \(itemId)")
    }
}
