# iOS 网络规范

## 1. API Client

```swift
// 协议定义
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}

// Endpoint
struct Endpoint {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let queryItems: [URLQueryItem]?
    let body: Encodable?
    let baseURL: URL

    var url: URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        components?.queryItems = queryItems
        return components?.url ?? baseURL
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// NetworkClient 实现
class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        return try decoder.decode(T.self, from: data)
    }

    func request(_ endpoint: Endpoint) async throws -> Data {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}

// NetworkError
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .networkUnavailable:
            return "Network unavailable"
        }
    }
}
```

## 2. API Service

```swift
// User API
protocol UserApiProtocol {
    func getUsers() async throws -> [User]
    func getUser(by id: Int) async throws -> User
    func createUser(_ user: CreateUserRequest) async throws -> User
    func updateUser(_ user: UpdateUserRequest) async throws -> User
    func deleteUser(by id: Int) async throws
}

class UserApi: UserApiProtocol {
    private let client: NetworkClientProtocol

    init(client: NetworkClientProtocol) {
        self.client = client
    }

    func getUsers() async throws -> [User] {
        let endpoint = Endpoint(
            path: "/users",
            method: .get,
            headers: nil,
            queryItems: nil,
            body: nil,
            baseURL: API.baseURL
        )
        return try await client.request(endpoint)
    }

    func getUser(by id: Int) async throws -> User {
        let endpoint = Endpoint(
            path: "/users/\(id)",
            method: .get,
            headers: nil,
            queryItems: nil,
            body: nil,
            baseURL: API.baseURL
        )
        return try await client.request(endpoint)
    }

    func createUser(_ user: CreateUserRequest) async throws -> User {
        let endpoint = Endpoint(
            path: "/users",
            method: .post,
            headers: nil,
            queryItems: nil,
            body: user,
            baseURL: API.baseURL
        )
        return try await client.request(endpoint)
    }
}
```

## 3. 认证

```swift
// AuthInterceptor
class AuthInterceptor: URLSessionInterceptor {
    private let tokenProvider: TokenProviderProtocol

    init(tokenProvider: TokenProviderProtocol) {
        self.tokenProvider = tokenProvider
    }

    func adapt(_ request: inout URLRequest) {
        if let token = tokenProvider.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

// TokenProvider
protocol TokenProviderProtocol {
    func getToken() -> String?
    func saveToken(_ token: String)
    func clearToken()
}
```

## 4. 请求重试

```swift
// 重试策略
struct RetryPolicy {
    let maxRetries: Int
    let baseDelay: TimeInterval

    func execute<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                if attempt < maxRetries - 1 {
                    let delay = baseDelay * pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }

        throw lastError ?? NetworkError.invalidResponse
    }
}

// 使用
let retryPolicy = RetryPolicy(maxRetries: 3, baseDelay: 1.0)

func getUsersWithRetry() async throws -> [User] {
    try await retryPolicy.execute {
        try await userApi.getUsers()
    }
}
```

## 5. 缓存

```swift
// URLCache
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .returnCacheDataElseLoad
configuration.urlCache = URLCache(
    memoryCapacity: 10 * 1024 * 1024,  // 10MB
    diskCapacity: 50 * 1024 * 1024      // 50MB
)

let session = URLSession(configuration: configuration)

// 使用 Cache
class UserCacheManager {
    private let cache = NSCache<NSString, NSData>()

    func cacheUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            cache.setObject(data as NSData, forKey: "users")
        }
    }

    func getCachedUsers() -> [User]? {
        guard let data = cache.object(forKey: "users") as Data?,
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return nil
        }
        return users
    }
}
```

## 6. 网络状态

```swift
// NetworkMonitor
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private(set) var isConnected = false
    private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied

            if path.usesInterfaceType(.wifi) {
                self?.connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self?.connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.connectionType = .ethernet
            } else {
                self?.connectionType = .unknown
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

// 使用
if NetworkMonitor.shared.isConnected {
    // 在线
} else {
    // 离线，显示缓存数据
}
```

## 7. 请求取消

```swift
// 取消任务
class UserListViewModel {
    private var fetchTask: Task<Void, Never>?

    func loadUsers() {
        fetchTask?.cancel()
        fetchTask = Task {
            do {
                let users = try await userApi.getUsers()
                self.users = users
            } catch is CancellationError {
                // 任务被取消
            } catch {
                self.error = error
            }
        }
    }

    func cancel() {
        fetchTask?.cancel()
    }
}
```