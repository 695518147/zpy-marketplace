# iOS 性能规范

## 1. 内存管理

```swift
// 使用 weak 避免循环引用
class UserListViewController: UIViewController {
    private weak var delegate: UserListDelegate?

    // 闭包捕获 self
    private lazy var fetchUsers = { [weak self] in
        guard let self = self else { return }
        self.viewModel.loadUsers()
    }
}

// 使用 autoreleasepool 释放内存
func processLargeData() {
    autoreleasepool {
        // 处理大量数据
        for item in largeDataSet {
            process(item)
        }
    }
}

// 及时释放大对象
func didReceiveImage(_ image: UIImage) {
    imageView.image = image
    // 大图片及时释放
    if let oldImage = imageView.image, oldImage !== image {
        // oldImage 释放
    }
}
```

## 2. 图片优化

```swift
// 使用合适的图片尺寸
func loadImage(from url: URL, targetSize: CGSize) async throws -> UIImage {
    let data = try await downloadData(from: url)
    guard let image = UIImage(data: data) else {
        throw ImageError.invalidData
    }

    // 调整图片大小
    return await resizeImage(image, to: targetSize)
}

func resizeImage(_ image: UIImage, to targetSize: CGSize) async -> UIImage {
    return await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            continuation.resume(returning: resizedImage)
        }
    }
}

// 使用 ImageIO 加载大图
import ImageIO

func downsample(imageAt url: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOptions) else {
        return nil
    }

    let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
    let downsampleOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ] as CFDictionary

    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
        return nil
    }

    return UIImage(cgImage: downsampledImage)
}
```

## 3. 列表优化

```swift
// UITableView 优化
class UserTableViewCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        nameLabel.text = nil
    }
}

// 使用预估高度
func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
}

// 预加载数据
func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    let userIds = indexPaths.map { viewModel.users[$0.row].id }
    viewModel.prefetchImages(for: userIds)
}
```

## 4. 启动优化

```swift
// AppDelegate 优化
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 延迟初始化非关键模块
        DispatchQueue.global(qos: .utility).async {
            DependencyContainer.shared.initialize()
        }
        return true
    }
}

// 使用懒加载
class UserListViewController: UIViewController {
    private lazy var viewModel: UserListViewModel = {
        return UserListViewModel(userService: UserService())
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        // 配置
        return tableView
    }()
}
```

## 5. 网络优化

```swift
// 压缩请求
var request = URLRequest(url: url)
request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")

// 批量请求
func fetchUsersAndOrders() async throws -> (users: [User], orders: [Order]) {
    async let users = userApi.getUsers()
    async let orders = orderApi.getOrders()
    return try await (users, orders)
}

// 图片缓存
import Kingfisher

func loadImage(url: URL, into imageView: UIImageView) {
    imageView.kf.setImage(
        with: url,
        placeholder: UIImage(systemName: "photo"),
        options: [
            .transition(.fade(0.2)),
            .cacheOriginalImage,
            .scaleFactor(UIScreen.main.scale)
        ]
    )
}
```

## 6. 数据库优化

```swift
// 使用批量操作
func batchInsert(users: [User]) throws {
    try db.execute { db in
        for user in users {
            try db.run("INSERT INTO users (id, name) VALUES (?, ?)",
                       arguments: [user.id, user.name])
        }
    }
}

// 使用索引
CREATE INDEX idx_user_name ON users(name);

// 分页查询
func fetchUsers(limit: Int, offset: Int) -> [User] {
    return db.prepare("SELECT * FROM users LIMIT ? OFFSET ?",
                     arguments: [limit, offset])
}

// 使用预编译语句
let statement = try db.prepare("SELECT * FROM users WHERE name = ?")
for row in try statement.bind(name) {
    // 处理
}
```

## 7. 动画优化

```swift
// 使用 shouldRasterize
func setupLayer() {
    myLayer.shouldRasterize = true
    myLayer.rasterizationScale = UIScreen.main.scale
}

// 使用 CADisplayLink
class AnimationController {
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0

    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }

    @objc func update(_ displayLink: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        // 使用 elapsed 更新动画
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
}
```

## 8. Instruments 使用

```swift
// Time Profiler
// 定位耗时操作

// Memory Graph
// 检测内存泄漏

// Leaks
// 查找内存泄漏

// Allocations
// 追踪内存分配

// 使用 os_signpost 进行自定义追踪
import os.log

let subsystem = "com.example.app"
let signpostLog = OSLog(subsystem: subsystem, category: "Performance")

func measurePerformance<T>(_ label: String, block: () throws -> T) rethrows -> T {
    let signpostID = OSSignpostID(log: signpostLog)
    os_signpost(.begin, log: signpostLog, name: label, signpostID: signpostID)

    let result = try block()

    os_signpost(.end, log: signpostLog, name: label, signpostID: signpostID)
    return result
}

// 使用
let users = try measurePerformance("FetchUsers") {
    try await userApi.getUsers()
}
```

## 9. 性能检测代码

```swift
// 检测主线程阻塞
func checkMainThread() {
    DispatchQueue.main.async {
        let start = CFAbsoluteTimeGetCurrent()
        // 操作
        let elapsed = CFAbsoluteTimeGetCurrent() - start

        if elapsed > 0.1 {
            print("Warning: Main thread blocked for \(elapsed)s")
        }
    }
}

// 检测内存峰值
import os.log

let memoryLog = OSLog(subsystem: "App", category: "Memory")

func logMemoryUsage() {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    if result == KERN_SUCCESS {
        let usedMemory = Double(info.resident_size) / 1024 / 1024
        os_log(.info, log: memoryLog, "Memory used: %.2f MB", usedMemory)
    }
}
```