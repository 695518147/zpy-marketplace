# Android 安全规范

## 1. 数据加密

```kotlin
// 使用 EncryptedSharedPreferences
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val sharedPreferences = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

// 存储敏感数据
sharedPreferences.edit().apply {
    putString("api_key", apiKey)
    putString("token", token)
    apply()
}

// EncryptedSharedPreferences 的读写
fun saveToken(token: String) {
    securePrefs.edit().putString("token", token).apply()
}

fun getToken(): String? {
    return securePrefs.getString("token", null)
}
```

## 2. 网络安全

```xml
<!-- network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-01-01">
            <pin digest="SHA-256">base64_hash</pin>
            <pin digest="SHA-256">backup_pin</pin>
        </pin-set>
    </domain-config>
</network-security-config>

<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ... >
```

## 3. ProGuard

```groovy
// app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

// proguard-rules.pro
// 保留模型类
-keep class com.example.app.data.model.** { *; }

// 保留 Retrofit
-keepattributes Signature
-keepattributes Exceptions
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

// 保留 Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
```

## 4. 权限管理

```kotlin
// 检查权限
if (ContextCompat.checkSelfPermission(
        context,
        Manifest.permission.CAMERA
    ) != PackageManager.PERMISSION_GRANTED
) {
    // 权限未授予
}

// 请求权限
private fun requestCameraPermission() {
    ActivityCompat.requestPermissions(
        this,
        arrayOf(Manifest.permission.CAMERA),
        REQUEST_CODE_CAMERA
    )
}

// 处理权限结果
override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray
) {
    when (requestCode) {
        REQUEST_CODE_CAMERA -> {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // 权限授予
            } else {
                // 权限拒绝
            }
        }
    }
}

// 运行时权限
private val permissionLauncher = registerForActivityResult(
    ActivityResultContracts.RequestPermission()
) { isGranted ->
    if (isGranted) {
        useCamera()
    } else {
        showPermissionDeniedMessage()
    }
}

permissionLauncher.launch(Manifest.permission.CAMERA)
```

## 5. 输入验证

```kotlin
// 验证用户输入
fun validateEmail(email: String): Boolean {
    return Patterns.EMAIL_ADDRESS.matcher(email).matches()
}

fun validatePassword(password: String): Boolean {
    return password.length >= 8 &&
           password.any { it.isDigit() } &&
           password.any { it.isLetter() }
}

// 使用 Zxcvbn 评估密码强度
fun evaluatePasswordStrength(password: String): PasswordStrength {
    val strength = PasswordStrengthCalculator.calculate(password)
    return when {
        strength.score < 2 -> PasswordStrength.WEAK
        strength.score < 4 -> PasswordStrength.MEDIUM
        else -> PasswordStrength.STRONG
    }
}
```

## 6. SQL 注入防护

```kotlin
// 使用 Room 参数化查询
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE name = :name")
    suspend fun findByName(name: String): User?

    @Query("SELECT * FROM users WHERE id = :id")
    suspend fun findById(id: Int): User?
}

// 使用 ContentProvider 时验证参数
fun query(uri: Uri, projection: Array<String>, selection: String?,
           selectionArgs: Array<String>, sortOrder: String?): Cursor? {
    // 验证 selection 参数
    if (!isValidSelection(selection)) {
        throw IllegalArgumentException("Invalid selection")
    }
    return super.query(uri, projection, selection, selectionArgs, sortOrder)
}
```

## 7. 安全存储

```kotlin
// 使用 Keystore 存储密钥
val keyStore = KeyStore.getInstance("AndroidKeyStore")
keyStore.load(null)

val keyGenerator = KeyGenerator.getInstance(
    KeyProperties.KEY_ALGORITHM_AES,
    "AndroidKeyStore"
)

val keyGenSpec = KeyGenParameterSpec.Builder(
    "my_key_alias",
    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
)
    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
    .setKeySize(256)
    .build()

keyGenerator.init(keyGenSpec)
keyGenerator.generateKey()

// 加密数据
val cipher = Cipher.getInstance("AES/GCM/NoPadding")
cipher.init(Cipher.ENCRYPT_MODE, keyStore.getKey("my_key_alias", null))
val encryptedData = cipher.doFinal(data.toByteArray())
```

## 8. 安全配置检查清单

- 启用 ProGuard/R8
- 使用 HTTPS
- 配置网络安全策略
- 使用 EncryptedSharedPreferences
- 验证用户输入
- 安全处理权限
- 定期更新依赖