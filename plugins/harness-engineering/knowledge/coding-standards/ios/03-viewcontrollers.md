# iOS ViewController 规范

## 1. ViewController 职责

- 管理视图生命周期
- 协调数据流
- 处理用户交互
- 不包含业务逻辑

## 2. ViewController 结构

```swift
class UserListViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: UserListViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        loadData()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "Users"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.refreshControl = refreshControl

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Binding
    private func bindViewModel() {
        viewModel.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showError(message)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions
    @objc private func handleRefresh() {
        viewModel.loadUsers()
    }

    // MARK: - Helpers
    private func loadData() {
        viewModel.loadUsers()
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: UserTableViewCell.identifier,
            for: indexPath
        ) as? UserTableViewCell else {
            return UITableViewCell()
        }

        let user = viewModel.users[indexPath.row]
        cell.configure(with: user)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = viewModel.users[indexPath.row]
        viewModel.didSelectUser(user)
    }
}
```

## 3. ViewController 命名

```swift
// 每个功能模块一个目录
Features/
├── Users/
│   ├── UserList/
│   │   ├── UserListViewController.swift
│   │   ├── UserListViewModel.swift
│   │   └── UserListCell.swift
│   └── UserDetail/
│       ├── UserDetailViewController.swift
│       └── UserDetailViewModel.swift
```

## 4. 避免臃肿

```swift
// 拆分到 extension
class UserListViewController: UIViewController {
    // 主要代码
}

// MARK: - UITableViewDataSource
extension UserListViewController: UITableViewDataSource {
    // DataSource 实现
}

// MARK: - UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    // Delegate 实现
}

// MARK: - Private Methods
private extension UserListViewController {
    func setupUI() { ... }
    func bindViewModel() { ... }
    func showError(_ message: String) { ... }
}
```

## 5. 视图控制器容器

```swift
// Container ViewController
class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let usersNav = UINavigationController(rootViewController: makeUsersListVC())
        usersNav.tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person"), tag: 0)

        let settingsNav = UINavigationController(rootViewController: makeSettingsVC())
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), tag: 1)

        viewControllers = [usersNav, settingsNav]
    }

    private func makeUsersListVC() -> UIViewController {
        return UserListViewController(viewModel: UserListViewModel(userService: UserService()))
    }

    private func makeSettingsVC() -> UIViewController {
        return SettingsViewController(viewModel: SettingsViewModel())
    }
}
```

## 6. 导航处理

```swift
// 使用 Coordinator 处理导航
protocol UserListViewControllerDelegate: AnyObject {
    func userListViewController(_ controller: UserListViewController, didSelectUser user: User)
}

class UserListViewController: UIViewController {
    weak var delegate: UserListViewControllerDelegate?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        delegate?.userListViewController(self, didSelectUser: user)
    }
}

// 或使用 Coordinator 直接
class UserListViewController: UIViewController {
    var coordinator: UserCoordinator?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.users[indexPath.row]
        coordinator?.showUserDetail(user)
    }
}
```

## 7. 生命周期

```swift
// 正确的生命周期处理
class UserDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次即将显示时刷新数据
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 开始动画等
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 保存状态
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 清理资源
    }

    deinit {
        // 清理
    }
}
```

## 8. 错误处理

```swift
extension UserListViewController {
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tag = 999
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }

    private func hideLoading() {
        view.viewWithTag(999)?.removeFromSuperview()
    }
}
```