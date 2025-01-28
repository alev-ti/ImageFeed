import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateUI(with profile: Profile)
    func updateAvatar(imageURL: URL)
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = UIColor(named: "YP White")
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0) // #AEAFB4
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP White")
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_btn") ?? UIImage(),
            target: self,
            action: #selector(didTapButton)
        )
        button.tintColor = UIColor(named: "YP Red")
        return button
    }()

    private let presenter: ProfileViewPresenterProtocol

    init(presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter.view = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustView()
        addSubviews()
        setupConstraints()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    // MARK: - ProfileViewControllerProtocol

    func updateUI(with profile: Profile) {
        nameLabel.text = profile.name()
        usernameLabel.text = profile.loginName()
        statusLabel.text = profile.bio ?? "No bio available"
    }

    func updateAvatar(imageURL: URL) {
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: imageURL,
            placeholder: UIImage(named: "stub_profile_img"),
            options: []
        ) { result in
            switch result {
            case .success(let value):
                print("[ProfileViewController/updateAvatar]: avatar img loaded from \(value.cacheType)")
            case .failure(let error):
                print("[ProfileViewController/updateAvatar]: error: \(error)")
            }
        }
    }

    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.presenter.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Private Methods

    private func adjustView() {
        view.backgroundColor = UIColor(named: "YP Black")
    }
    
    private func addSubviews() {
        let viewsArray: [UIView] = [
            profileImageView,
            nameLabel,
            usernameLabel,
            statusLabel,
            logoutButton
        ]
        
        viewsArray.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statusLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 40),
            logoutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc
    private func didTapButton() {
        presenter.didTapLogoutButton()
    }
}
