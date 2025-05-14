import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled = false

    func load(request _: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_: Float) {}

    func setProgressHidden(_: Bool) {}
}
