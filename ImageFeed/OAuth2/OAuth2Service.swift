//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 10.05.2025.
//

import UIKit

// Структура для парсинга ответа сервера
struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let createdAt: Int

    // Используем ключи, чтобы соответствовать названиям в JSON
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

final class OAuth2Service {

    static let shared = OAuth2Service()
    private init() {}

    var token: String? = nil
    let tokenStorage = OAuth2TokenStorage()

    func fetchAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "RequestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create OAuth token request."])))
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                // Обрабатываем ответ и сохраняем токен
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken)) // Возвращаем токен
                } catch {
                    print("Decoding error: \(error)") // Логируем ошибку декодирования
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token"])))
                }
            case .failure(let error):
                print("Network error: \(error)") // Логируем сетевую ошибку
                completion(.failure(error)) // Возвращаем ошибку
            }
        }
        task.resume() // Запускаем задачу
    }

    func fetchAuthCode(from viewController: UIViewController, completion: @escaping
                       (Result<String, Error>) -> Void) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController else {
            completion(.failure(NSError(domain: "ViewControllerError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to instantiate WebViewViewController."])))
            return
        }

        webViewController.delegate = viewController as? WebViewViewControllerDelegate

        // Показ webViewController
        viewController.present(webViewController, animated: true, completion: nil)
    }

    // Метод для создания запроса
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Invalid base URL")
            return nil
        }

        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Invalid token URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
