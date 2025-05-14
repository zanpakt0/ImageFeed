import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {

    // MARK: - 1. Проверка вызова viewDidLoad у презентера

    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let presenter = ImagesListPresenterSpy()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as! ImagesListViewController

        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    // MARK: - 2. Проверка обновления таблицы

    func testUpdateTableViewReloadsData() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as! ImagesListViewController
        let tableView = UITableView()
        viewController.setValue(tableView, forKey: "tableView")

        class TableViewMock: UITableView {
            var reloadCalled = false
            override func reloadData() {
                reloadCalled = true
            }
        }

        let tableViewMock = TableViewMock()
        viewController.setValue(tableViewMock, forKey: "tableView")

        // when
        viewController.updateTableView()

        // then
        XCTAssertTrue(tableViewMock.reloadCalled)
    }

    // MARK: - 3. Проверка insertRows при обновлении с новым количеством

    func testUpdateTableViewWithOldCountInsertsRows() {
        // given
        let viewController = ImagesListViewController()
        let tableView = UITableView()
        let presenter = ImagesListPresenterSpy()
        presenter.setPhotos(Array(repeating: Photo.mock, count: 5))

        viewController.presenter = presenter
        viewController.setValue(tableView, forKey: "tableView")

        let tableViewMock = TableViewInsertSpy()
        viewController.setValue(tableViewMock, forKey: "tableView")

        // when
        viewController.updateTableView(oldCount: 3)

        // then
        XCTAssertEqual(tableViewMock.insertedIndexPaths, [IndexPath(row: 3, section: 0), IndexPath(row: 4, section: 0)])
    }

    // MARK: - 4. Проверка didSelectRow — инициирует segue

    func testDidSelectRowPerformsSegue() {
        // given
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenterSpy()

        presenter.setPhotos(Array(repeating: Photo.mock, count: 3))

        let tableView = UITableView()
        viewController.setValue(tableView, forKey: "tableView")

        viewController.presenter = presenter

        let indexPath = IndexPath(row: 1, section: 0)

        // when
        viewController.tableView(tableView, didSelectRowAt: indexPath)

        // then
        XCTAssertEqual(viewController.performedSegueIdentifier, "ShowSingleImage")
        XCTAssertEqual(viewController.performedSegueSender as? IndexPath, indexPath)
    }


}
