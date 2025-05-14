import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    var photos: [Photo] = []

    func setPhotos(_ photos: [Photo]) {
        self.photos = photos
    }

    private(set) var viewDidLoadCalled = false
    private(set) var willDisplayCellCalledWith: IndexPath?
    private(set) var didTapLikeCalledWith: IndexPath?
    private(set) var updateTableViewCalledWith: Int?
    private(set) var reloadCellCalledWith: IndexPath?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func willDisplayCell(at indexPath: IndexPath) {
        willDisplayCellCalledWith = indexPath
    }

    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalledWith = indexPath
    }

    func updateTableView(oldCount: Int) {
        updateTableViewCalledWith = oldCount
    }

    func reloadCell(at indexPath: IndexPath) {
        reloadCellCalledWith = indexPath
    }
}
