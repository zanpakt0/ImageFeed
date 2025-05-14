import Foundation
import Kingfisher
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar(with urlString: String)
    func updateProfile(with profile: Profile)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var profileService = ProfileService.shared
    var presenter: ProfilePresenterProtocol?

    init(presenter: ProfilePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) не поддерживается, используй init(presenter:)")
    }

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(resource: .placeholder)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(resource: .ypBlack)
        setupLayout()
        avatarImageView.layer.masksToBounds = true
        assert(presenter != nil, "ProfilePresenter не был сконфигурирован")
        presenter?.viewDidLoad()
        addObserver()
    }

    // MARK: - Notification Observers

    func updateProfile(with profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No bio available"
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }

    @objc private func updateAvatar(notification: Notification) {
        guard isViewLoaded,
              let userInfo = notification.userInfo,
              let profileImageURL = userInfo["URL"] as? String,
              let url = URL(string: profileImageURL) else {
            return
        }

        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .placeholder),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        ) { result in
            switch result {
            case .success:
                print("Аватарка успешно обновлена!")
            case let .failure(error):
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")

                print("Получено уведомление об обновлении аватарки:", notification.userInfo ?? "пустой userInfo")
            }
        }
    }

    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
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
        showLogoutAlert()
    }

     func showLogoutAlert() {
        ProfileLogoutService.shared.showLogoutAlert(from: self)
    }

    private func updateProfileUI(with profile: Profile) {
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "No bio available"

        if let avatarURL = ProfileImageService.shared.avatarURL {
            updateAvatar(with: avatarURL)
        }
    }

    private func fetchProfileImageURL(for username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(imageURL):
                    self?.updateAvatar(with: imageURL)
                case let .failure(error):
                    print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateAvatar(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .placeholder),
            options: [.transition(.fade(0.3)), .cacheOriginalImage]
        )
    }
}
