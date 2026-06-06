# Android 架构规范

## 1. 架构模式

采用 Clean Architecture + MVVM。

```
presentation (UI)
├── activity/
├── fragment/
├── viewmodel/
└── composable/ (if using Compose)

domain (Business Logic)
├── model/
├── repository/
└── usecase/

data (Data Layer)
├── repository/
├── remote/
├── local/
└── model/
```

## 2. MVVM 模式

```kotlin
// ViewModel - 持有 UI 状态
class UserListViewModel(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<UserListUiState>(UserListUiState.Loading)
    val uiState: StateFlow<UserListUiState> = _uiState.asStateFlow()

    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UserListUiState.Loading
            try {
                val users = getUsersUseCase()
                _uiState.value = UserListUiState.Success(users)
            } catch (e: Exception) {
                _uiState.value = UserListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

// UI State
sealed class UserListUiState {
    data object Loading : UserListUiState()
    data class Success(val users: List<User>) : UserListUiState()
    data class Error(val message: String) : UserListUiState()
}

// Activity/Fragment
class UserListFragment : Fragment() {
    private val viewModel: UserListViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewLifecycleOwner.lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                when (state) {
                    is UserListUiState.Loading -> showLoading()
                    is UserListUiState.Success -> showUsers(state.users)
                    is UserListUiState.Error -> showError(state.message)
                }
            }
        }
    }
}
```

## 3. UseCase

```kotlin
// 每个 UseCase 只做一件事
class GetUsersUseCase(
    private val userRepository: UserRepository
) {
    suspend operator fun invoke(): List<User> {
        return userRepository.getUsers()
    }
}

class GetUserDetailUseCase(
    private val userRepository: UserRepository
) {
    suspend operator fun invoke(userId: Int): Result<User> {
        return try {
            val user = userRepository.getUserById(userId)
            if (user != null) {
                Result.success(user)
            } else {
                Result.failure(UserNotFoundException(userId))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

## 4. Repository

```kotlin
// Repository 接口定义在 domain 层
interface UserRepository {
    suspend fun getUsers(): List<User>
    suspend fun getUserById(id: Int): User?
    suspend fun saveUser(user: User)
    suspend fun deleteUser(id: Int)
}

// Repository 实现定义在 data 层
class UserRepositoryImpl(
    private val remoteDataSource: UserRemoteDataSource,
    private val localDataSource: UserLocalDataSource
) : UserRepository {

    override suspend fun getUsers(): List<User> {
        return remoteDataSource.getUsers()
    }

    override suspend fun getUserById(id: Int): User? {
        return localDataSource.getUserById(id)
            ?: remoteDataSource.getUserById(id)?.also {
                localDataSource.saveUser(it)
            }
    }
}
```

## 5. 依赖注入 (Hilt)

```kotlin
// Module
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideUserRepository(
        remoteDataSource: UserRemoteDataSource,
        localDataSource: UserLocalDataSource
    ): UserRepository {
        return UserRepositoryImpl(remoteDataSource, localDataSource)
    }
}

// Activity/Fragment 注入
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    @Inject lateinit var viewModel: MainViewModel
}

// ViewModel 注入
@HiltViewModel
class UserListViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {
    // ...
}
```

## 6. 数据流向

```
User Action → ViewModel → UseCase → Repository → DataSource
                ↓
            StateFlow
                ↓
              View (Compose/XML)
```

## 7. 模块化

```
app/
├── feature/
│   ├── user/
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── di/
│   └── order/
└── core/
    ├── network/
    ├── database/
    └── common/
```

## 8. 单Activity架构

```kotlin
// 使用 Navigation Component
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}

// navigation/nav_graph.xml
<navigation app:startDestination="@id/userListFragment">
    <fragment
        android:id="@+id/userListFragment"
        android:name="com.example.UserListFragment"
        android:label="Users"
        app:action="@id/action_userList_to_userDetail">
        <argument android:name="userId" app:argType="int" />
    </fragment>
</navigation>
```