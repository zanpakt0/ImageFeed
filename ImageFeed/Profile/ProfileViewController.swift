import Foundation
import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    private var profileImageServiceObserver: NSObjectProtocol?
    var profileService = ProfileService.shared

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .photo)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = profileService.currentProfile?.loginName
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .ypGray)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = profileService.currentProfile?.name
        label.textColor = UIColor(resource: .ypWhite)
        label.textAlignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 23, weight: .bold),
            .kern: -0.078
        ]

        label.attributedText = NSAttributedString(string: profileService.currentProfile?.name ?? "", attributes: attributes)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = profileService.currentProfile?.bio
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(resource: .ypWhite)

        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .exit), for: .normal)
        button.tintColor = UIColor(resource: .ypRed)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializers

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }

    deinit {
        removeObserver()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupLayout()
        fetchProfileData()
        updateAvatar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let path = UIBezierPath(
            roundedRect: avatarImageView.bounds,
            byRoundingCorners: [.topLeft],
            cornerRadii: CGSize(width: 61, height: 61)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        avatarImageView.layer.mask = mask
    }

    // MARK: - Notification Observers

    private func addObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }

    @objc private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else { print("Неверный или пустой URL аватара")
            return
        }

        let processor = RoundCornerImageProcessor(cornerRadius: 20)

        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .photo),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage,
                .processor(processor)
            ]
        ) { result in
            switch result {
            case .success:
                print("Аватарка успешно обновлена!")
            case let .failure(error):
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
            }
        }
    }

    private func removeObserver() {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupLayout() {
        view.addSubview(avatarImageView)
        view.addSubview(loginNameLabel)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 99),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func didTapLogoutButton() {
        print("Logout tapped, will be implemented later")
    }

    private func fetchProfileData() {
        guard let token = OAuth2TokenStorage().token else {
            print("Ошибка: токен отсутствует")
            return
        }

        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(profile):
                    self?.updateProfileUI(with: profile)
                case let .failure(error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateProfileUI(with profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No bio available"
    }
}
