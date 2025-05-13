import Kingfisher
import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet private var ImageView: UIImageView!

    @IBOutlet private var dateLabel: UILabel!

    @IBOutlet private var likeButton: UIButton!

    @IBAction private func likeButtonClicked(_: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }

    weak var delegate: ImagesListCellDelegate?

    static let reuseIdentifier = "ImagesListCell"
    override func awakeFromNib() {
        super.awakeFromNib()

        likeButton.setImage(UIImage(resource: .heartNoActive), for: .normal)
        likeButton.setImage(UIImage(resource: .heartActive), for: .selected)
    }

    func setImage(with url: URL?) {
        ImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .placeholder),
            options: [.transition(.fade(0.3))]
        )
    }

    func setIsLiked(_ isLiked: Bool) {
        likeButton.isSelected = isLiked
    }

    func configure(with model: ImagesListCellModel) {
        setImage(with: model.imageURL)
        dateLabel.text = model.date
        setIsLiked(model.isLiked)
    }
}
