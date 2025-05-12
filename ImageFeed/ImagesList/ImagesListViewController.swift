import Kingfisher
import ProgressHUD
import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    private var imageListObserver: NSObjectProtocol?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        ImagesListService.shared.fetchPhotosNextPage()
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count

        photos = ImagesListService.shared.photos

        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        let url = URL(string: photo.thumbImageURL)
        cell.setImage(with: url)

        let date = photo.createdAt.map { dateFormatter.string(from: $0) } ?? "—"
        let isLiked = photo.isLiked
        let model = ImagesListCellModel(imageURL: url, date: date, isLiked: isLiked)
        cell.configure(with: model)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        UIBlockingProgressHUD.show()

        let photo = photos[indexPath.row]
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = ImagesListService.shared.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                }
                case .failure(let error):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    print("Ошибка при лайке \(error)")
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось поставить лайк", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
    }
}
