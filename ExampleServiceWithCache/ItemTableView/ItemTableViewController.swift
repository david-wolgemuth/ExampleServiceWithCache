//
//  ViewController.swift
//  ExampleServiceWithCache
//
//  Created by David Wolgemuth on 11/12/17.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit

class ItemTableViewController: UITableViewController {
    
    var itemIds = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0...240 {
            itemIds.append(
                Int(arc4random_uniform(60))  // demo caching by putting only 60 ids across 240 rows (produce duplicates) 
            )
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemIds.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        let itemId = itemIds[indexPath.row]
        cell.setItem(withId: itemId)
        return cell
    }
}
