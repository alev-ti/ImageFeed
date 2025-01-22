import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func updateAvatar()
    func loadProfile()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        profileLogoutService: ProfileLogoutServiceProtocol
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }

    func viewDidLoad() {
        loadProfile()
        updateAvatar()
        setupObserver()
    }

    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }

    func updateAvatar() {
        guard let avatarURLString = profileImageService.avatarURL,
              let avatarURL = URL(string: avatarURLString) else {
            return
        }
        view?.updateAvatar(imageURL: avatarURL)
    }

    func loadProfile() {
        if let profile = profileService.profile {
            view?.updateUI(with: profile)
        } else {
            print("[ProfileViewPresenter/loadProfile]: profile not available.")
        }
    }

    private func setupObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
}
