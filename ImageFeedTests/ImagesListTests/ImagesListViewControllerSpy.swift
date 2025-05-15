import UIKit
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewController {
    var performedSegueIdentifier: String?
    var performedSegueSender: Any?

    var spyPresenter: ImagesListPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let presenter = spyPresenter else {
            assertionFailure("spyPresenter was not set before viewDidLoad")
            return
        }
        self.presenter = presenter
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        performedSegueIdentifier = segue.identifier
        performedSegueSender = sender
    }

    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        performedSegueIdentifier = identifier
        performedSegueSender = sender
    }
}
