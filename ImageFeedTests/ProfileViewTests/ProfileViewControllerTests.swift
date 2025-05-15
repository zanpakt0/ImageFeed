@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    // MARK: - Шпион-презентер

    final class ProfilePresenterSpy: ProfilePresenterProtocol {
        weak var view: ProfileViewControllerProtocol?
        private(set) var viewDidLoadCalled = false
        private(set) var didTapLogoutCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didTapLogout() {
            didTapLogoutCalled = true
        }
    }

    // MARK: - Тесты

    func testViewDidLoadCallsPresenterViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testUpdateProfileSetsLabelsCorrectly() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        _ = viewController.view

        let profile = Profile(username: "test_user", name: "John Doe", loginName: "@johndoe", bio: "iOS Developer")

        // when
        viewController.updateProfile(with: profile)

        // then
        XCTAssertEqual(viewController.nameLabel.text, profile.name)
        XCTAssertEqual(viewController.loginNameLabel.text, profile.loginName)
        XCTAssertEqual(viewController.descriptionLabel.text, profile.bio)
    }

    func testUpdateAvatarSetsImage() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        _ = viewController.view

        // when
        let url = "https://example.com/avatar.png"
        viewController.updateAvatar(with: url)

        // then
        XCTAssertNotNil(viewController.avatarImageView.image)
    }

    func testDidTapLogoutButtonCallsPresenter() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController
        _ = viewController.view

        // when
        viewController.didTapLogoutButton()

        // then
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
}
