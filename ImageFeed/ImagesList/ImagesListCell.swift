import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet private var ImageView: UIImageView!

    @IBOutlet private var dateLabel: UILabel!

    @IBOutlet private var likeButton: UIButton!

    static let reuseIdentifier = "ImagesListCell"

    func configure(with model: ImagesListCellModel) {
        ImageView.image = model.image
        dateLabel.text = model.date
        let likeButtonImage = model.isLiked ? UIImage(named: "HeartActive") : UIImage(named: "HeartNoActive")
        likeButton.setImage(likeButtonImage, for: .normal)
    }
}
