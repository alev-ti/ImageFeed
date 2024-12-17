import UIKit

final class ProfileViewController: UIViewController {
    
    private lazy var profileImageView: UIImageView = {
        let image = UIImage(named: "avatar")
        let view = UIImageView(image: image)
        return view
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
    
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustView()
        addSubviews()
        setupConstraints()
        loadProfile()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
    
    private func loadProfile() {
        if let profile = profileService.profile {
            updateUI(with: profile)
        } else {
            print("Profile not available. Make sure fetchProfile was called in SplashViewController.")
        }
    }
    
    private func updateUI(with profile: Profile) {
        nameLabel.text = profile.name()
        usernameLabel.text = profile.loginName()
        statusLabel.text = profile.bio ?? "No bio available"
    }
    
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
    private func didTapButton() {}
}
