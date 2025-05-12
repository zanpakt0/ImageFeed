import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data,
               let response = response as? HTTPURLResponse,
               200..<300 ~= response.statusCode {
                fulfillCompletionOnTheMainThread(.success(data))
            } else if let error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else if let response = response as? HTTPURLResponse {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: request) { data, _, error in
            if let error {
                print("[objectTask]: NetworkError - \(error.localizedDescription), request: \(request)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data else {
                let error = NSError(domain: "NetworkError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("[objectTask]: NetworkError - No data, request: \(request)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                }
            } catch {
                print("[objectTask]: DecodingError - \(error.localizedDescription), data: \(String(data: data, encoding: .utf8) ?? "nil"), request: \(request)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
