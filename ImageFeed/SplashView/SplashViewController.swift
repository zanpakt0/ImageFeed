import Foundation
import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()
    private var profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var isFetchingProfile = false

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .splashScreenLogo))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token)
        } else {
            showAuthViewController()
        }
    }

    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchProfile(_ token: String) {
        guard !isFetchingProfile else {
            return
        }
        isFetchingProfile = true

        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            guard let self else {
                return
            }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case let .success(profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { _ in
                    self.switchToTabBarController()
                }
            case let .failure(error):
                showAlert(with: "Ошибка", message: error.localizedDescription)
            }
        }
    }

    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid Configuration")
            }

            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarController") as! TabBarController

            window.rootViewController = tabBarController
        }
    }

    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("AuthViewController not found in storyboard")
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode _: String) {
        DispatchQueue.main.async {
            vc.dismiss(animated: true) {
                guard let token = self.storage.token else {
                    self.showAlert(with: "Ошибка", message: "Не удалось получить токен")
                    return
                }
                self.fetchProfile(token)
            }
        }
    }
}
