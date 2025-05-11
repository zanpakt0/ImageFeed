//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 10.05.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let oauth2Service = OAuth2Service.shared

    @IBAction func loginButoonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showWebView", sender: nil)
    }



    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView",
           let webVC = segue.destination as? WebViewViewController {
            webVC.delegate = self
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            self.oauth2Service.fetchAuthToken(with: code) { result in
                switch result {
                case .success(let token):
                    print("Token received: \(token)")
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                case .failure(let error):
                    print("Failed to fetch token: \(error.localizedDescription)")
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
}
