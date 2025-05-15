import ProgressHUD
import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let createdAt: Int

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

    var token: String?
    let tokenStorage = OAuth2TokenStorage()

    private var activeRequests: [String: [(Result<String, Error>) -> Void]] = [:]
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue", attributes: .concurrent)

    func fetchToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        queue.async(flags: .barrier) {
            if self.activeRequests[code] != nil {
                self.activeRequests[code]?.append(completion)
                return
            } else {
                self.activeRequests[code] = [completion]
            }
        }

        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NSError(domain: "RequestError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create OAuth token request."])
            print("[fetchToken]: RequestError - \(error.localizedDescription), code: \(code)")
            complete(code: code, with: .failure(error))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else {
                return
            }

            switch result {
            case let .success(tokenResponse):
                tokenStorage.token = tokenResponse.accessToken
                complete(code: code, with: .success(tokenResponse.accessToken))
            case let .failure(error):
                complete(code: code, with: .failure(error))
            }
        }
        task.resume()
    }

    private func complete(code: String, with result: Result<String, Error>) {
        queue.async(flags: .barrier) {
            let completions = self.activeRequests[code]
            self.activeRequests[code] = nil
            completions?.forEach { $0(result) }
        }
    }

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
