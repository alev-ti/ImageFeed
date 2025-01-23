import XCTest
@testable import ImageFeed


class ProfileViewPresenterTests: XCTestCase {
    var sut: ProfileViewPresenter!
    var mockProfileService: MockProfileService!
    var mockProfileImageService: MockProfileImageService!
    var mockProfileLogoutService: MockProfileLogoutService!
    var mockView: MockProfileViewController!

    override func setUp() {
        super.setUp()
        mockProfileService = MockProfileService()
        mockProfileImageService = MockProfileImageService()
        mockProfileLogoutService = MockProfileLogoutService()
        mockView = MockProfileViewController()

        sut = ProfileViewPresenter(
            profileService: mockProfileService,
            profileImageService: mockProfileImageService,
            profileLogoutService: mockProfileLogoutService
        )
        sut.view = mockView
    }

    override func tearDown() {
        sut = nil
        mockProfileService = nil
        mockProfileImageService = nil
        mockProfileLogoutService = nil
        mockView = nil
        super.tearDown()
    }

    func testViewDidLoad_LoadsProfileAndUpdatesAvatar() {
        let profile = Profile(username: "testUser", bio: "Test Bio", firstName: "TestFirstName", lastName: "TestLastName")
        mockProfileService.profile = profile
        print(profile)
        mockProfileImageService.avatarURL = "https://example.com/example_avatar.png"

        sut.viewDidLoad()

        XCTAssertTrue(mockView.updateUICalled)
        XCTAssertTrue(mockView.updateAvatarCalled)
    }

    func testDidTapLogoutButton_ShowsLogoutAlert() {
        sut.didTapLogoutButton()
        XCTAssertTrue(mockView.showLogoutAlertCalled)
    }
}

// Моки для тестов
class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        if let profile = profile {
            completion(.success(profile))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
        }
    }
}

class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let avatarURL = avatarURL {
            completion(.success(avatarURL))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
        }
    }
}

class MockProfileLogoutService: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}

class MockProfileViewController: ProfileViewControllerProtocol {
    var updateUICalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false

    func updateUI(with profile: Profile) {
        updateUICalled = true
    }

    func updateAvatar(imageURL: URL) {
        updateAvatarCalled = true
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}


