# Android 性能规范

## 1. 内存优化

```kotlin
// 使用 lazy 初始化
class MyActivity : AppCompatActivity() {
    private val viewModel: MyViewModel by viewModels()
    private val adapter: MyAdapter by lazy { MyAdapter() }
}

// 避免内存泄漏
class MyActivity : AppCompatActivity() {
    private var handler: Handler? = null

    override fun onDestroy() {
        super.onDestroy()
        handler?.removeCallbacksAndMessages(null)
        handler = null
    }
}

// 使用 WeakReference
class MyCache {
    private val cache = WeakHashMap<String, Any>()

    fun put(key: String, value: Any) {
        cache[key] = value
    }
}
```

## 2. 图片加载

```kotlin
// 使用 Coil 或 Glide
// Coil
@Composable
fun UserAvatar(url: String) {
    AsyncImage(
        model = url,
        contentDescription = "Avatar",
        modifier = Modifier.size(48.dp),
        placeholder = painterResource(R.drawable.ic_placeholder),
        error = painterResource(R.drawable.ic_error)
    )
}

// 使用 ImageRequest.Builder
val request = ImageRequest.Builder(context)
    .data(imageUrl)
    .crossfade(true)
    .placeholder(R.drawable.placeholder)
    .error(R.drawable.error)
    .memoryCachePolicy(CachePolicy.ENABLED)
    .build()

// 释放资源
override fun onDestroy() {
    super.onDestroy()
    imageView.dispose()
}
```

## 3. 列表优化

```kotlin
// RecyclerView 优化
class UserAdapter : ListAdapter<User, UserViewHolder>(UserDiffCallback()) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): UserViewHolder {
        val binding = ItemUserBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return UserViewHolder(binding)
    }

    override fun onBindViewHolder(holder: UserViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    // 使用 setHasFixedSize
    recyclerView.setHasFixedSize(true)

    // 使用 stable ID
    override fun getItemId(position: Int): Long = getItem(position).id
    adapter.setHasStableIds(true)
}

// DiffUtil
class UserDiffCallback : DiffUtil.ItemCallback<User>() {
    override fun areItemsTheSame(oldItem: User, newItem: User): Boolean {
        return oldItem.id == newItem.id
    }

    override fun areContentsTheSame(oldItem: User, newItem: User): Boolean {
        return oldItem == newItem
    }
}
```

## 4. 协程优化

```kotlin
// 使用 structured concurrency
viewModelScope.launch {
    // 自动取消
}

// 避免在 ViewModel 中启动太多协程
class UserViewModel : ViewModel() {
    private val jobs = mutableListOf<Job>()

    fun loadData() {
        jobs += viewModelScope.launch {
            // ...
        }
    }

    override fun onCleared() {
        super.onCleared()
        jobs.forEach { it.cancel() }
    }
}

// 使用 shareIn 共享 Flow
val users: Flow<List<User>> = repository.getUsers()
    .shareIn(viewModelScope, replay = 1, started = SharingStarted.WhileSubscribed())
```

## 5. 启动优化

```kotlin
// 使用 Splash Screen API
installSplashScreen()

// 延迟初始化
class App : Application() {
    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) {
            // 开发环境初始化
        }
    }
}

// 使用 App Startup
// Manifest.xml
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    android:exported="false">
    <meta-data
        android:name="com.example.AppInitializer"
        android:value="androidx.startup" />
</provider>

// Initializer
class AppInitializer : Initializer<Unit> {
    override fun create(context: Context) {
        // 初始化
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}
```

## 6. 网络优化

```kotlin
// 使用 OkHttp 缓存
val cache = Cache(context.cacheDir, 10 * 1024 * 1024) // 10MB

val client = OkHttpClient.Builder()
    .cache(cache)
    .build()

// 压缩请求
val request = Request.Builder()
    .url(url)
    .header("Accept-Encoding", "gzip")
    .build()

// 批量请求
suspend fun fetchUsersAndOrders(): Pair<List<User>, List<Order>> = withContext(Dispatchers.IO) {
    val usersDeferred = async { api.getUsers() }
    val ordersDeferred = async { api.getOrders() }
    Pair(usersDeferred.await(), ordersDeferred.await())
}
```

## 7. 数据库优化

```kotlin
// 使用 Room 事务
@Transaction
suspend fun insertUsers(users: List<User>) {
    userDao.insertAll(users)
}

// 使用索引
@Dao
interface UserDao {
    @Query("SELECT * FROM users WHERE name = :name")
    suspend fun findByName(name: String): User?

    @Query("SELECT * FROM users WHERE email = :email")
    suspend fun findByEmail(email: String): User?
}

// Entity 添加索引
@Entity(
    indices = [
        Index(value = ["name"]),
        Index(value = ["email"], unique = true)
    ]
)
class User { ... }

// 分页查询
@Query("SELECT * FROM users LIMIT :limit OFFSET :offset")
suspend fun getUsers(limit: Int, offset: Int): List<User>
```

## 8. Compose 性能

```kotlin
// 使用 remember 避免不必要重组
@Composable
fun HeavyComponent(data: List<String>) {
    val sortedData = remember(data) {
        data.sorted()
    }

    LazyColumn {
        items(sortedData) { item ->
            Text(item)
        }
    }
}

// 使用 derivedStateOf
@Composable
fun TodoList(tasks: List<Task>) {
    val completedTasks by remember {
        derivedStateOf { tasks.filter { it.isCompleted } }
    }
}

// 使用 key
LazyColumn {
    items(tasks, key = { it.id }) { task ->
        TaskItem(task)
    }
}
```

## 9. 性能检测工具

```kotlin
// 使用 Systrace
import android.os.Trace

Trace.beginSection("loadData")
loadData()
Trace.endSection()

// 使用 Debug
Debug.startMethodTracing("my_trace")
// 操作
Debug.stopMethodTracing()

// 使用 Benchmarks
@Benchmark
fun myBenchmark() {
    // 测试代码
}
```