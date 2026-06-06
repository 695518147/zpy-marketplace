# iOS 命名规范

## 1. 通用规则

- 使用有意义的英文命名
- 变量、函数使用 camelCase
- 类型、类名、协议名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE
- 文件名与类型名一致

## 2. 类命名

```swift
// ViewController - 以 Controller 结尾
class UserListViewController: UIViewController
class UserDetailViewController: UIViewController

// ViewModel
class UserListViewModel
class UserDetailViewModel

// View - 以 View 结尾
class UserListHeaderView: UIView
class UserAvatarView: UIView

// Cell - 以 Cell 结尾
class UserTableViewCell: UITableViewCell
class UserCollectionViewCell: UICollectionViewCell

// Model / Entity
struct User
class Order

// 协议
protocol UserRepositoryProtocol {
    func getUser(by id: Int) async throws -> User?
}

protocol ViewModelDelegate: AnyObject {
    func viewModelDidUpdate(_ viewModel: Any)
}

// Manager / Service
class CacheManager
class AuthService
```

## 3. 函数命名

```swift
// 使用动词或动词短语
func getUser(by id: Int) async throws -> User
func saveUser(_ user: User) async throws
func deleteUser(by id: Int) async throws
func isUserActive() -> Bool

// 事件处理
func didTapButton(_ sender: UIButton)
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
func textFieldDidChange(_ textField: UITextField)

// 闭包参数
func fetchUsers(completion: @escaping (Result<[User], Error>) -> Void)
func updateUser(_ user: User, completion: (Bool) -> Void)
```

## 4. 变量命名

```swift
// 普通变量
var userName: String = "张三"
var pageSize: Int = 20
var isDeleted: Bool = false

// 可选类型
var user: User?
var errorMessage: String?

// 集合变量
var users: [User] = []
var userMap: [Int: User] = [:]
var userSet: Set<User> = []

// 布尔变量
var isActive: Bool = true
var hasPermission: Bool = false
var canEdit: Bool = true

// 静态常量
static let maxRetryCount = 3
static let defaultPageSize = 20

// 全局常量
private enum Constants {
    static let apiBaseURL = "https://api.example.com"
    static let maxCacheSize = 100
}
```

## 5. 类型命名

```swift
// 枚举
enum UserStatus {
    case active
    case inactive
    case deleted
}

enum HttpStatusCode: Int {
    case ok = 200
    case notFound = 404
    case serverError = 500
}

// 结构体
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// 扩展
extension User {
    var isValid: Bool {
        return !name.isEmpty && !email.isEmpty
    }
}

// 泛型
struct ListResponse<T: Codable> {
    let data: [T]
    let total: Int
}
```

## 6. 文件命名

```
// ViewController
UserListViewController.swift
UserDetailViewController.swift

// ViewModel
UserListViewModel.swift
UserDetailViewModel.swift

// View
UserListHeaderView.swift
UserTableViewCell.swift

// Model
User.swift
Order.swift

// Service
AuthService.swift
NetworkService.swift

// Extension
UIView+Extensions.swift
String+Extensions.swift

// Utility
Constants.swift
Logger.swift
```

## 7. 命名禁忌

- 避免使用中文拼音
- 避免使用无意义命名
- 避免使用缩写（除非通用）
- 避免使用匈牙利命名法
- 避免在变量名后加类型后缀（如 userString、userArray）