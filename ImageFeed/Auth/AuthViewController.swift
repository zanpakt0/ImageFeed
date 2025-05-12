import Kingfisher
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    let oauth2Service = OAuth2Service.shared

    @IBAction private func loginButoonTapped(_: UIButton) {
        performSegue(withIdentifier: "showWebView", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.identifier == "showWebView",
           let webVC = segue.destination as? WebViewViewController {
            webVC.delegate = self
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true, completion: nil)
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) {
            UIBlockingProgressHUD.show()
            self.oauth2Service.fetchToken(with: code) { [weak self] result in
                guard let self else {
                    return
                }

                UIBlockingProgressHUD.dismiss()

                switch result {
                case let .success(token):
                    print("Token received: \(token)")
                    delegate?.authViewController(self, didAuthenticateWithCode: code)
                case let .failure(error):
                    print("Failed to fetch token: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                }
            }
        }
    }
}
