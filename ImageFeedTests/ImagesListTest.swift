import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    var presenter: ImagesListPresenter!
    var mockView: MockImagesListViewController!
    var mockImageService: MockImagesListService!
    var mockOAuth2TokenStorage: MockOAuth2TokenStorage!
    
    override func setUp() {
        super.setUp()
        mockView = MockImagesListViewController()
        mockImageService = MockImagesListService()
        mockOAuth2TokenStorage = MockOAuth2TokenStorage()
        
        presenter = ImagesListPresenter(
            imageService: mockImageService,
            oauth2TokenStorage: mockOAuth2TokenStorage
        )
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockImageService = nil
        mockOAuth2TokenStorage = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        // Given
        mockOAuth2TokenStorage.token = "testToken"
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockImageService.fetchPhotosNextPageCalled)
        XCTAssertEqual(mockImageService.fetchPhotosNextPageToken, "testToken")
        XCTAssertEqual(presenter.getPreviousPhotosCount(), 0)
    }
    
    func testFetchPhotosNextPage() {
        // Given
        mockOAuth2TokenStorage.token = "testToken"
        
        // When
        presenter.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(mockImageService.fetchPhotosNextPageCalled)
        XCTAssertEqual(mockImageService.fetchPhotosNextPageToken, "testToken")
    }
    
    func testChangeLike() {
        // Given
        let photoId = "testPhotoId"
        let isLike = true
        
        // When
        presenter.changeLike(photoId: photoId, isLike: isLike) { success in
            // Then
            XCTAssertTrue(success)
            XCTAssertTrue(self.mockImageService.changeLikeCalled)
            XCTAssertEqual(self.mockImageService.changeLikePhotoId, photoId)
            XCTAssertEqual(self.mockImageService.changeLikeIsLike, isLike)
        }
    }
    
    func testGetPreviousPhotosCount() {
        // Given
        presenter.setPreviousPhotosCount(10)
        
        // When
        let count = presenter.getPreviousPhotosCount()
        
        // Then
        XCTAssertEqual(count, 10)
    }
    
    func testSetPreviousPhotosCount() {
        // When
        presenter.setPreviousPhotosCount(15)
        
        // Then
        XCTAssertEqual(presenter.getPreviousPhotosCount(), 15)
    }
}

// MARK: - Mocks

final class MockImagesListViewController: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled = true
    }
}

final class MockImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var fetchPhotosNextPageToken: String?
    var changeLikeCalled = false
    var changeLikePhotoId: String?
    var changeLikeIsLike: Bool?
    
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        fetchPhotosNextPageToken = token
        completion(.success([]))
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        changeLikePhotoId = photoId
        changeLikeIsLike = isLike
        completion(.success(()))
    }
    
    func clearImagesListData() {
        photos = []
    }
}

final class MockOAuth2TokenStorage: OAuth2TokenStorageProtocol {
    var token: String?
    
    func clearToken() {
        token = nil
    }
}
