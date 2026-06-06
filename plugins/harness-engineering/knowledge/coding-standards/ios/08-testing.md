# iOS 测试规范

## 1. 测试框架

使用 XCTest + Mockingjay + Combine。

```swift
import XCTest
@testable import App

class UserServiceTests: XCTestCase {
    private var sut: UserService!
    private var mockNetworkClient: MockNetworkClient!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        sut = UserService(networkClient: mockNetworkClient)
    }

    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        super.tearDown()
    }
}
```

## 2. 单元测试

```swift
class UserViewModelTests: XCTestCase {
    private var viewModel: UserListViewModel!
    private var mockUserService: MockUserService!

    @MainActor
    override func setUp() {
        super.setUp()
        mockUserService = MockUserService()
        viewModel = UserListViewModel(userService: mockUserService)
    }

    @MainActor
    func testLoadUsersSuccess() async {
        // Arrange
        let users = [User(id: 1, name: "Alice"), User(id: 2, name: "Bob")]
        mockUserService.getUsersResult = .success(users)

        // Act
        await viewModel.loadUsers()

        // Assert
        XCTAssertEqual(viewModel.users, users)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testLoadUsersFailure() async {
        // Arrange
        mockUserService.getUsersResult = .failure(NetworkError.invalidResponse)

        // Act
        await viewModel.loadUsers()

        // Assert
        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
```

## 3. Mock 使用

```swift
// Mock NetworkClient
class MockNetworkClient: NetworkClientProtocol {
    var requestResult: Result<Data, Error>?
    var requestCalled = false
    var lastEndpoint: Endpoint?

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestCalled = true
        lastEndpoint = endpoint

        guard let result = requestResult else {
            throw NetworkError.invalidResponse
        }

        let data = try result.get()
        return try JSONDecoder().decode(T.self, from: data)
    }

    func request(_ endpoint: Endpoint) async throws -> Data {
        requestCalled = true
        lastEndpoint = endpoint

        guard let result = requestResult else {
            throw NetworkError.invalidResponse
        }

        return try result.get()
    }
}

// Mock Service
class MockUserService: UserServiceProtocol {
    var getUsersResult: Result<[User], Error>?
    var getUserResult: Result<User, Error>?

    func getUsers() async throws -> [User] {
        guard let result = getUsersResult else {
            throw NetworkError.invalidResponse
        }
        return try result.get()
    }

    func getUser(by id: Int) async throws -> User {
        guard let result = getUserResult else {
            throw NetworkError.invalidResponse
        }
        return try result.get()
    }
}
```

## 4. 异步测试

```swift
// 使用 async/await 测试
func testAsyncLoad() async throws {
    // Arrange
    let expectation = XCTestExpectation(description: "Load users")

    // Act
    Task {
        await viewModel.loadUsers()
        expectation.fulfill()
    }

    // Wait
    await fulfillment(of: [expectation], timeout: 5)

    // Assert
    XCTAssertFalse(viewModel.users.isEmpty)
}

// 使用主线程测试
@MainActor
func testMainActor() async {
    await viewModel.loadUsers()
    XCTAssertFalse(viewModel.isLoading)
}
```

## 5. UI 测试

```swift
import XCTest

class UserListUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    func testUserListDisplayed() {
        // 等待列表加载
        XCTAssertTrue(app.tables["userTableView"].waitForExistence(timeout: 5))

        // 检查用户显示
        XCTAssertTrue(app.tables.cells["UserCell_0"].exists)
        XCTAssertTrue(app.staticTexts["Alice"].exists)
    }

    func testTapUser() {
        // 点击用户
        app.tables.cells["UserCell_0"].tap()

        // 验证导航
        XCTAssertTrue(app.navigationBars["User Detail"].exists)
    }

    func testPullToRefresh() {
        // 下拉刷新
        let tableView = app.tables["userTableView"]
        tableView.refreshControl?.swipeDown()

        // 验证刷新
        XCTAssertTrue(app.activityIndicators["loading"].waitForExistence(timeout: 2))
    }
}
```

## 6. Combine 测试

```swift
import XCTest
import Combine

class UserViewModelCombineTests: XCTestCase {
    private var viewModel: UserListViewModel!
    private var cancellables = Set<AnyCancellable>()

    func testPublishedUsers() {
        // Arrange
        let expectation = expectation(description: "users published")
        viewModel.$users
            .dropFirst()
            .sink { users in
                XCTAssertFalse(users.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        viewModel.loadUsers()

        // Assert
        waitForExpectations(timeout: 5)
    }

    func testLoadingState() {
        // Arrange
        let expectation = expectation(description: "loading state")
        var states: [Bool] = []

        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                states.append(isLoading)
                if states.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        viewModel.loadUsers()

        // Assert
        waitForExpectations(timeout: 5)
        XCTAssertEqual(states, [true, false])
    }
}
```

## 7. 测试覆盖

```bash
# 运行测试
xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 15'

# 生成覆盖率报告
xcodebuild test -scheme App -destination 'platform=iOS Simulator,name=iPhone 15' \
    -enableCodeCoverage YES \
    -resultBundlePath TestResults

# 查看报告
xcrun xccov view --report TestResults.xcresult
```

## 8. 测试原则

- 测试应该独立，不依赖其他测试
- 每个测试只验证一个概念
- 使用清晰有意义的测试名称（testMethod_Scenario_Expected）
- AAA 模式（Arrange-Act-Assert）
- 测试边界条件
- 保持测试快速
- Mock 外部依赖