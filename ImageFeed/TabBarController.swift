import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let listsViewController = storyboard.instantiateViewController(withIdentifier: "ListsViewController") as? ImagesListViewController else {
            assertionFailure("Не удалось загрузить ListsViewController")
            return
        }

        let profilePresenter = ProfilePresenter()
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profilePresenter.view = profileViewController
        viewControllers = [listsViewController, profileViewController]

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: UIImage(resource: .tabProfileActive)
        )
    }
}
