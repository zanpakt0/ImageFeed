import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        clearToken()
        cleanCookies()
        clearProfileData()

        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
    }

    private func clearToken() {
        OAuth2TokenStorage().token = nil
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func clearProfileData() {
        ProfileService.shared.clean()
        ProfileImageService.shared.clearAvatar()
        ImagesListService.shared.clearPhotos()
    }

    func showLogoutAlert(from viewController: UIViewController) {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)

        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }

        let cancelAction = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }
}
