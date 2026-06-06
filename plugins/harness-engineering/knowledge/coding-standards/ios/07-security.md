# iOS 安全规范

## 1. 数据存储

```swift
// 使用 Keychain 存储敏感数据
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.example.app"

    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.loadFailed(status)
        }

        return result as? Data
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}

// 使用 UserDefaults 存储非敏感数据
UserDefaults.standard.set(token, forKey: "auth_token")
UserDefaults.standard.string(forKey: "auth_token")
```

## 2. 网络安全

```swift
// 使用证书固定 (Certificate Pinning)
import Security

final class CertificatePinning {
    private let validPublicKeys: [String] = [
        "sha256/publicKey1...",
        "sha256/publicKey2..."
    ]

    func validate(serverTrust: SecTrust, domain: String) -> Bool {
        guard let certificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            return false
        }

        for certificate in certificates {
            let publicKey = SecCertificateCopyKey(certificate)
            let publicKeyData = SecKeyCopyExternalRepresentation(publicKey!, nil) as Data?
            let hash = publicKeyData?.sha256()

            if validPublicKeys.contains(hash ?? "") {
                return true
            }
        }

        return false
    }
}

// ATS 配置 (Info.plist)
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.example.com</key>
        <dict>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

## 3. 加密

```swift
// 使用 CryptoKit
import CryptoKit

// 对称加密
func encrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.seal(data, using: key)
    return sealedBox.combined!
}

func decrypt(_ data: Data, using key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    return try AES.GCM.open(sealedBox, using: key)
}

// 生成密钥
let key = SymmetricKey(size: .bits256)

// 哈希
let hash = SHA256.hash(data: data)
let hashString = hash.map { String(format: "%02x", $0) }.joined()
```

## 4. 权限管理

```swift
// 请求相机权限
import AVFoundation

func requestCameraPermission() async -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)

    switch status {
    case .authorized:
        return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    case .denied, .restricted:
        return false
    @unknown default:
        return false
    }
}

// 检查权限
func checkCameraPermission() -> Bool {
    return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
}

// 位置权限
import CoreLocation

func requestLocationPermission() {
    let manager = CLLocationManager()
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
}
```

## 5. 输入验证

```swift
// 验证邮箱
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

// 验证密码强度
func validatePassword(_ password: String) -> PasswordValidationResult {
    var errors: [String] = []

    if password.count < 8 {
        errors.append("Password must be at least 8 characters")
    }

    if !password.contains(where: { $0.isNumber }) {
        errors.append("Password must contain at least one number")
    }

    if !password.contains(where: { $0.isLetter }) {
        errors.append("Password must contain at least one letter")
    }

    if password.contains(where: { "?!@#$%^&*()_+-=[]{}|;':\",./<>?".contains($0) }) {
        errors.append("Password should not contain special characters")
    }

    return PasswordValidationResult(isValid: errors.isEmpty, errors: errors)
}

// 清理输入
func sanitizeInput(_ input: String) -> String {
    return input
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "<script>", with: "")
}
```

## 6. 代码混淆

```swift
// 使用 Identifier Obfuscation
enum AppConstants {
    static let apiBaseURL = "https://api.example.com"
    static let apiKey = "xxxxx"  // 加密存储
}

// 使用 Swift reflective 时避免暴露
class SecureDataHolder {
    private let _internalValue: String

    init(value: String) {
        self._internalValue = value
    }

    var value: String {
        return _internalValue  // 不直接暴露
    }
}
```

## 7. 防调试

```swift
// 检测调试器
import Foundation

func isBeingDebugged() -> Bool {
    var info = kinfo_proc()
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride

    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)

    return (result == 0) && (info.kp_proc.p_flag & P_TRACED) != 0
}

// 在 Release 中禁用
#if !DEBUG
if isBeingDebugged() {
    exit(0)
}
#endif
```

## 8. 安全配置检查清单

- 使用 HTTPS
- 配置 ATS
- 使用 Keychain 存储敏感数据
- 验证用户输入
- 加密存储
- 防调试检测
- 代码混淆
- 定期更新依赖