import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()

    private(set) var photos: [Photo] = []
    private var isLoading = false
    private var currentPage = 0
    private let tokenStorage: OAuth2TokenStorage
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage(), session: URLSession = .shared) {
        self.tokenStorage = tokenStorage
        self.session = session
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func clearPhotos() {
        photos.removeAll()
        currentPage = 0
    }

    func fetchPhotosNextPage() {
        guard !isLoading else {
            return
        }

        guard let token = tokenStorage.token else {
            print("Ошибка: отсутствует токен")
            return
        }

        isLoading = true
        currentPage += 1

        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(currentPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else {
                return
            }
            isLoading = false

            if let error {
                print("Ошибка загрузки фотографий: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Ошибка HTTP: \(httpResponse.statusCode)")
                return
            }

            guard let data else {
                print("Ошибка: нет данных")
                return
            }

            do {
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { self.convertToPhoto(from: $0) }
                let filteredPhotos = newPhotos.filter { newPhotos in
                    !self.photos.contains(where: { $0.id == newPhotos.id })
                }
                DispatchQueue.main.async{
                    self.photos.append(contentsOf: filteredPhotos)
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "ImagesListService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Токен не найден"])))
            return
        }
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ImagesListService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Некорректный URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { [weak self] _, response, error in
            guard let self else {
                return
            }

            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "ImagesListService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Ошибка HTTP: \(httpResponse.statusCode)"])))
                }
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        description: photo.description,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )

                    self.photos[index] = newPhoto

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: nil,
                        userInfo: ["photos": self.photos]
                    )
                }
                completion(.success(()))
            }
        }

        task.resume()
    }

    private func convertToPhoto(from result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        let createdAt = result.createdAt.flatMap { ISO8601DateFormatter().date(from: $0) } ?? Date()
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAt,
            description: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
