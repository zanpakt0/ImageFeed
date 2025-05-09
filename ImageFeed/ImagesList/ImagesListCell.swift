//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Zhukov Konstantin on 06.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    @IBOutlet private weak var imagesView: UIImageView!

    @IBOutlet private weak var dateLabel: UILabel!

    @IBOutlet private weak var likeButton: UIButton!

    func configure(with model: ImagesListCellModel) {
        imagesView.image = model.image
        dateLabel.text = model.date
        let likeImageName = model.isLiked ? "HeartActive" : "HeartNoActive"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }

    static let reuseIdentifier = "ImagesListCell"
}
