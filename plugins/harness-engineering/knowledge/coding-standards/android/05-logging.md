# Android 日志规范

## 1. 日志框架

使用 Android Logging 或自定义日志封装。

```kotlin
// 自定义日志类
object Logger {
    private const val TAG = "App"

    fun d(message: String, tag: String = TAG) {
        if (BuildConfig.DEBUG) {
            android.util.Log.d(tag, message)
        }
    }

    fun i(message: String, tag: String = TAG) {
        if (BuildConfig.DEBUG) {
            android.util.Log.i(tag, message)
        }
    }

    fun w(message: String, tag: String = TAG) {
        android.util.Log.w(tag, message)
    }

    fun e(message: String, throwable: Throwable? = null, tag: String = TAG) {
        android.util.Log.e(tag, message, throwable)
    }
}
```

## 2. 日志级别

| 级别 | 使用场景 |
|------|----------|
| `VERBOSE` | 详细调试信息 |
| `DEBUG` | 调试信息，开发环境 |
| `INFO` | 重要业务节点 |
| `WARN` | 警告信息，可能有问题 |
| `ERROR` | 错误，需要关注 |

```kotlin
Logger.d("User loaded: $userId")
Logger.i("Order created: $orderId")
Logger.w("Retry attempt $attempt failed")
Logger.e("Failed to load user", throwable)
```

## 3. 日志格式

```kotlin
// 结构化日志
Logger.d("User action: userId=${userId}, action=$action, result=$result")

// 使用 BuildConfig 判断
if (BuildConfig.DEBUG) {
    Logger.d("Detailed debug info: $detailedData")
}

// 参数化日志
val userId = 123
val userName = "Alice"
Logger.d("User info: id=%d, name=%s", userId, userName)
```

## 4. 日志时机

```kotlin
// 在 ViewModel 中记录
class UserViewModel : ViewModel() {
    fun loadUser(userId: Int) {
        Logger.d("Loading user: id=$userId")
        viewModelScope.launch {
            try {
                val user = repository.getUserById(userId)
                Logger.i("User loaded: id=$userId, name=${user.name}")
                _state.value = UserState.Success(user)
            } catch (e: Exception) {
                Logger.e("Failed to load user: id=$userId", e)
                _state.value = UserState.Error(e.message)
            }
        }
    }
}
```

## 5. 日志脱敏

```kotlin
// 不要记录敏感信息
Logger.d("User login: username=$username")  // OK
Logger.d("User login: password=$password")  // 禁止

// 使用掩码
fun maskPassword(password: String): String {
    return "*".repeat(password.length)
}

fun maskCreditCard(cardNumber: String): String {
    return if (cardNumber.length >= 4) {
        "*".repeat(cardNumber.length - 4) + cardNumber.takeLast(4)
    } else {
        cardNumber
    }
}
```

## 6. 日志配置

```kotlin
// 初始化日志
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        initLogger()
    }

    private fun initLogger() {
        if (BuildConfig.DEBUG) {
            // 调试模式：输出所有日志
            Logger.setMinLevel(Log.DEBUG)
        } else {
            // 发布模式：只输出 Error
            Logger.setMinLevel(Log.ERROR)
        }
    }
}

// 统一的日志标签
object LogTags {
    const val NETWORK = "Network"
    const val DATABASE = "Database"
    const val UI = "UI"
    const val BUSINESS = "Business"
}
```

## 7. Crash 报告

```kotlin
// 设置默认未捕获异常处理器
Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
    Logger.e("Uncaught exception on thread ${thread.name}", throwable)
    // 上报到 Crash 报告服务
    CrashReportService.report(throwable)
}
```

## 8. 禁止事项

- 不要在日志中记录密码、密钥等敏感信息
- 不要在生产环境记录 Debug 日志
- 不要在循环中记录大量日志
- 不要记录用户输入（可能有恶意代码）