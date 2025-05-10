//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 10.05.2025.
//

import Foundation
import UIKit

final class SplashViewController: UIViewController {

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Проверяем, есть ли токен
        if storage.token != nil {
            // Если есть токен — переходим к главному экрану
            switchToTabBarController()
        } else {
            // Если токена нет — вызываем флоу авторизации
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    private func switchToTabBarController() {
        // Получаем экземпляр окна приложения
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }

        // Загружаем TabBarController из сториборда
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        // Устанавливаем rootViewController
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            self.switchToTabBarController()
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }

            // Устанавливаем делегат
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
