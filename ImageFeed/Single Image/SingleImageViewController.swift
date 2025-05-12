import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else {
                return
            }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: Outlets

    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var scrollView: UIScrollView!

    // MARK: viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self

        guard let image else {
            return
        }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }

    @IBAction private func didTapBackButton(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func didTapShareButton(_: UIButton) {
        guard let image else {
            return
        }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }

    private func updateImageViewSize() {
        guard let image else {
            return
        }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: image.size.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: image.size.height).isActive = true
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)

        let newContentSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let horizontalInset = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let verticalInset = max(0, (visibleRectSize.height - newContentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        imageView
    }
}
