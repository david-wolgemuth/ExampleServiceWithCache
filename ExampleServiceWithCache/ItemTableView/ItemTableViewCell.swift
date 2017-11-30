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
        ItemService.shared.fetch(itemId: id) { (err, item) in
            if let err = err {
                self.updateLabels(text: "ERROR", detail: err)
                return
            }
            guard let item = item else {
                return // reusable cell, other item received error, this cell is now seeing error
            }
            if self.itemId != item.id {
                return  // reusable cell no longer being used for this item
            }
            self.updateLabels(text: "\(item.id)", detail: item.fancyString())
        }
    }
    
    private func updateLabels(text: String?, detail: String?) {
        textLabel?.text = text
        detailTextLabel?.text = detail
        setNeedsLayout()
        layoutIfNeeded()
    }
}
