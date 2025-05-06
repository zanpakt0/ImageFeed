//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 06.05.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: PROPERTIES

    private let imagesListView = ImagesListView()

    private let photosName: [String] = Array(0..<20).map{ "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view = imagesListView

        imagesListView.tableView.dataSource = self
        imagesListView.tableView.delegate = self

        imagesListView.tableView.rowHeight = 200
    }

    // MARK: - SETUP
}

// MARK: UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }

        let isLiked = indexPath.row % 2 == 0

        let cellData = ImagesListCellModel(
            image: image,
            date: dateFormatter.string(from: Date()),
            isLiked: isLiked
        )

        cell.setupCell(with: cellData)
    }
}

// MARK: UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }

        let imageViewWidth = tableView.bounds.width
        let imageWidth = image.size.width
        let scale = (imageWidth != 0) ? imageViewWidth / imageWidth : 0
        let cellHeight = image.size.height * scale

        return cellHeight
    }
}
