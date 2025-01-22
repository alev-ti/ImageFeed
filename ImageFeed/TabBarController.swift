import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let profileService = ProfileService.shared
        let profileImageService = ProfileImageService.shared
        let profileLogoutService = ProfileLogoutService.shared
        

        let profilePresenter = ProfileViewPresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: profileLogoutService
        )

        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")

        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
