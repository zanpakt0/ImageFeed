import UIKit

final class TableViewInsertSpy: UITableView {
    var insertedIndexPaths: [IndexPath] = []

    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedIndexPaths = indexPaths
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }
}
