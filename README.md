# ExampleServiceWithCache

iOS - Demo Async Item Service With Cache

### Demo

Demo of api can be viewed in [ItemTableViewCell](./ExampleServiceWithCache/ItemTableView/ItemTableViewCell.swift):

```swift
class ItemTableViewCell: UITableViewCell, ItemServiceObserverTarget {
    func trigger() {
        ItemService.shared.fetch(self, itemId: id)    
    }
    func itemService(_ itemService: ItemService, didFetch item: Item) {
        self.textLabel?.text = item.title
    }
}
```

### Features of Service

 - Observers can tag along when existing requests are made.
   - 2 controllers request the same item -- only 1 request is executed, but both are informed on completion.
 - Puts requests into background queue, pulls back into main queue before informing observers.
 - Handles both successes and failures.
 - Singleton caches objects into memory for fast access.
 - Dumps the cache in case of memory warnings.
