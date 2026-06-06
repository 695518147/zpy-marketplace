# iOS 架构规范

## 1. 架构模式

采用 MVVM + Coordinator 架构。

```
App/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Coordinators/
│   ├── AppCoordinator.swift
│   └── UserCoordinator.swift
├── Features/
│   └── Users/
│       ├── Views/
│       │   ├── UserListViewController.swift
│       │   └── UserListViewModel.swift
│       ├── Models/
│       │   └── User.swift
│       └── Services/
│           └── UserService.swift
├── Core/
│   ├── Network/
│   ├── Storage/
│   └── Extensions/
└── Resources/
```

## 2. MVVM 模式

```swift
// ViewModel
@MainActor
class UserListViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil

        do {
            users = try await userService.getUsers()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// ViewController (UIKit)
class UserListViewController: UIViewController {
    private let viewModel: UserListViewModel

    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// View (SwiftUI)
struct UserListView: View {
    @StateObject private var viewModel: UserListViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.users) { user in
                    UserRowView(user: user)
                }
            }
        }
        .task {
            await viewModel.loadUsers()
        }
    }
}
```

## 3. Coordinator 模式

```swift
// Coordinator 协议
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

// AppCoordinator
class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        let userCoordinator = UserCoordinator(navigationController: UINavigationController())
        userCoordinator.start()
        childCoordinators.append(userCoordinator)

        window.rootViewController = userCoordinator.navigationController
    }
}

// UserCoordinator
class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = UserListViewModel(userService: UserService())
        let viewController = UserListViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }

    func showUserDetail(user: User) {
        let viewModel = UserDetailViewModel(user: user)
        let detailVC = UserDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(detailVC, animated: true)
    }
}
```

## 4. Service 层

```swift
// 协议定义
protocol UserServiceProtocol {
    func getUsers() async throws -> [User]
    func getUser(by id: Int) async throws -> User?
    func createUser(_ user: User) async throws -> User
    func deleteUser(by id: Int) async throws
}

// Service 实现
class UserService: UserServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let cacheManager: CacheManagerProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient(),
         cacheManager: CacheManagerProtocol = CacheManager()) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }

    func getUsers() async throws -> [User] {
        // 实现逻辑
    }
}
```

## 5. Repository 模式

```swift
// Repository 协议
protocol UserRepositoryProtocol {
    func getUsers() async throws -> [User]
    func saveUser(_ user: User) async throws
}

// Repository 实现
class UserRepository: UserRepositoryProtocol {
    private let remoteDataSource: UserRemoteDataSource
    private let localDataSource: UserLocalDataSource

    func getUsers() async throws -> [User] {
        do {
            let users = try await remoteDataSource.getUsers()
            try await localDataSource.saveUsers(users)
            return users
        } catch {
            return try await localDataSource.getUsers()
        }
    }
}
```

## 6. 依赖注入

```swift
// 手动注入
class UserListViewController {
    private let viewModel: UserListViewModel

    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
    }
}

// Factory
final class DependencyContainer {
    static let shared = DependencyContainer()

    func makeUserService() -> UserServiceProtocol {
        return UserService(
            networkClient: makeNetworkClient(),
            cacheManager: makeCacheManager()
        )
    }

    private func makeNetworkClient() -> NetworkClientProtocol {
        return NetworkClient()
    }

    private func makeCacheManager() -> CacheManagerProtocol {
        return CacheManager()
    }
}

// 使用
let viewModel = UserListViewModel(
    userService: DependencyContainer.shared.makeUserService()
)
```

## 7. 单向数据流

```swift
// Action
enum UserListAction {
    case loadUsers
    case selectUser(User)
    case deleteUser(Int)
}

// State
struct UserListState {
    var users: [User] = []
    var isLoading: Bool = false
    var errorMessage: String?
}

// Reducer
@MainActor
func reduce(state: inout UserListState, action: UserListAction) -> AsyncStream<UserListEffect> {
    switch action {
    case .loadUsers:
        state.isLoading = true
        return loadUsersEffect()

    case .selectUser(let user):
        return Just(.showUserDetail(user)).eraseToAsyncStream()

    case .deleteUser(let id):
        return deleteUserEffect(id: id)
    }
}
```