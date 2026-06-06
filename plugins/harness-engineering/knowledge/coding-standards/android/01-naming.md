# Android 命名规范

## 1. 通用规则

- 使用有意义的英文命名
- 变量和函数使用 camelCase
- 类型、类名、接口名使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE
- 文件名使用 camelCase 或 PascalCase

## 2. 包命名

```
com.company.project
├── data
│   ├── repository
│   ├── remote
│   └── local
├── domain
│   ├── model
│   ├── repository
│   └── usecase
├── ui
│   ├── feature
│   ├── component
│   └── theme
└── di
```

## 3. 类命名

```kotlin
// Activity - 以 Activity 结尾
class MainActivity : AppCompatActivity()
class UserDetailActivity : AppCompatActivity()

// Fragment - 以 Fragment 结尾
class UserListFragment : Fragment()
class UserDetailFragment : Fragment()

// ViewModel - 以 ViewModel 结尾
class UserListViewModel : ViewModel()
class UserDetailViewModel : ViewModel()

// Service - 以 Service 结尾
class SyncService : Service()
class DownloadService : Service()

// Adapter - 以 Adapter 结尾
class UserListAdapter : RecyclerView.Adapter<...>()
class ViewPagerAdapter : FragmentStateAdapter()

// 实体类
data class User(val id: Int, val name: String)
class Order

// 接口
interface UserRepository {
    suspend fun getUserById(id: Int): User?
}

interface OnItemClickListener {
    fun onItemClick(item: Item)
}
```

## 4. 函数命名

```kotlin
// 使用动词或动词短语
fun getUserById(id: Int): User?
fun saveUser(user: User)
fun deleteUser(id: Int)
fun isUserActive(): Boolean

// 事件处理
fun onClick(view: View)
fun onItemSelected(position: Int)
fun onRefresh()

// 扩展函数
fun View.hide() {
    visibility = View.GONE
}

fun String.isValidEmail(): Boolean {
    return android.util.Patterns.EMAIL_ADDRESS.matcher(this).matches()
}
```

## 5. 变量命名

```kotlin
// 普通变量
var userName: String = "张三"
var pageSize: Int = 20
var isDeleted: Boolean = false

// 私有变量
private var _userList: List<User>? = null
private val _cache = mutableMapOf<String, Any>()

// 集合变量
val userList: List<User> = emptyList()
val userMap: Map<Int, User> = emptyMap()
val userSet: Set<User> = emptySet()

// 常量
const val MAX_RETRY_COUNT = 3
const val DEFAULT_PAGE_SIZE = 20
const val API_BASE_URL = "https://api.example.com"

// 布尔变量
val isActive: Boolean = true
val hasPermission: Boolean = false
```

## 6. 资源命名

```
// 布局文件 - activity_ / fragment_ / item_ / dialog_
activity_main.xml
fragment_user_list.xml
item_user.xml
dialog_confirm.xml

// 视图 ID - 小写下划线
<TextView
    android:id="@+id/tv_user_name"
    ... />

// 字符串资源 - 小写下划线或点分隔
<string name="app_name">My App</string>
<string name="user_not_found">User not found</string>

// 颜色 - 小写下划线
<color name="white">#FFFFFF</color>
<color name="primary">#2196F3</color>
```

## 7. 命名禁忌

- 避免使用中文拼音
- 避免使用无意义命名
- 避免使用缩写（除非通用）
- 避免使用匈牙利命名法