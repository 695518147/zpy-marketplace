# Android 协程规范

## 1. 协程基础

```kotlin
// 在 ViewModel 中使用
class UserViewModel(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {

    private val _userState = MutableStateFlow<UserState>(UserState.Idle)
    val userState: StateFlow<UserState> = _userState.asStateFlow()

    fun loadUser(userId: Int) {
        viewModelScope.launch {
            _userState.value = UserState.Loading
            _userState.value = try {
                val user = getUserUseCase(userId)
                UserState.Success(user)
            } catch (e: Exception) {
                UserState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

// 在 Activity/Fragment 中使用
lifecycleScope.launch {
    viewModel.userState.collect { state ->
        when (state) {
            is UserState.Loading -> showLoading()
            is UserState.Success -> showUser(state.user)
            is UserState.Error -> showError(state.message)
        }
    }
}
```

## 2. Coroutine Scope

```kotlin
// ViewModelScope - ViewModel 销毁时自动取消
class MyViewModel : ViewModel() {
    fun doSomething() {
        viewModelScope.launch {
            // 自动在 ViewModel 销毁时取消
        }
    }
}

// lifecycleScope - Activity/Fragment 销毁时取消
class MyFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewLifecycleOwner.lifecycleScope.launch {
            // 在 View 销毁时取消
        }
    }
}

// 自定义 Scope
private val myScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

// 手动取消
private val job = viewModelScope.launch {
    // ...
}
job.cancel()
```

## 3. Dispatchers

```kotlin
// IO - 网络、数据库等 IO 操作
viewModelScope.launch(Dispatchers.IO) {
    val users = api.getUsers()  // 网络请求
    localDatabase.saveUsers(users)  // 数据库操作
}

// Main - UI 操作
viewModelScope.launch(Dispatchers.Main) {
    _state.value = UserState.Success(users)
}

// Default - CPU 密集型操作
viewModelScope.launch(Dispatchers.Default) {
    val result = processLargeData(data)  // 计算密集
}

// 使用 withContext 切换
suspend fun loadData(): List<User> = withContext(Dispatchers.IO) {
    api.getUsers()
}
```

## 4. Flow

```kotlin
// StateFlow - 用于 UI 状态
private val _uiState = MutableStateFlow<UiState>(UiState.Idle)
val uiState: StateFlow<UiState> = _uiState.asStateFlow()

// SharedFlow - 用于事件
private val _events = MutableSharedFlow<Event>()
val events: SharedFlow<Event> = _events.asSharedFlow()

// 冷流 - 数据源
fun getUsers(): Flow<List<User>> = flow {
    while (true) {
        val users = api.getUsers()
        emit(users)
        delay(5000)  // 定期刷新
    }
}.catch { e ->
    emit(emptyList())
}.flowOn(Dispatchers.IO)

// 转换 Flow
users
    .map { it.name }
    .filter { name -> name.isNotEmpty() }
    .distinctUntilChanged()
    .onEach { names -> updateNames(names) }
    .launchIn(viewModelScope)
```

## 5. 异常处理

```kotlin
// try-catch
viewModelScope.launch {
    try {
        val user = api.getUser(id)
        _state.value = UserState.Success(user)
    } catch (e: HttpException) {
        _state.value = UserState.Error("HTTP Error: ${e.code()}")
    } catch (e: Exception) {
        _state.value = UserState.Error(e.message ?: "Unknown error")
    }
}

// catch 操作符
viewModelScope.launch {
    api.getUsers()
        .catch { e ->
            _state.value = UserState.Error(e.message ?: "Unknown error")
            emit(emptyList())  // 需要 emit 一个值
        }
        .collect { users ->
            _state.value = UserState.Success(users)
        }
}

// Result
suspend fun getUser(id: Int): Result<User> = try {
    Result.success(api.getUser(id))
} catch (e: Exception) {
    Result.failure(e)
}

viewModelScope.launch {
    getUser(id).fold(
        onSuccess = { user -> _state.value = UserState.Success(user) },
        onFailure = { error -> _state.value = UserState.Error(error.message) }
    )
}
```

## 6. 取消协程

```kotlin
// 检查取消状态
viewModelScope.launch {
    for (item in items) {
        ensureActive()  // 检查是否取消
        process(item)
    }
}

// withTimeout
withTimeout(5000L) {
    val result = api.getUser(id)
}

// 清理资源
class MyViewModel : ViewModel() {
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onCleared() {
        super.onCleared()
        scope.cancel()
    }
}
```

## 7. 协程与 LiveData

```kotlin
// LiveData 转换为 Flow
val users: LiveData<List<User>> = liveData {
    emit(api.getUsers())
}

// Flow 转换为 LiveData
val userFlow: Flow<User> = ...
val userLiveData: LiveData<User> = userFlow.asLiveData()

// 使用 liveData builder
val user: LiveData<Result<User>> = liveData {
    emit(Result.Loading)
    emit(getUserUseCase(userId))
}
```

## 8. 常见错误

```kotlin
// 错误：在主线程执行 IO 操作
fun loadUsers() {
    val users = api.getUsers()  // 网络请求在主线程
    _state.value = UserState.Success(users)
}

// 正确：使用 withContext
fun loadUsers() {
    viewModelScope.launch {
        val users = withContext(Dispatchers.IO) {
            api.getUsers()
        }
        _state.value = UserState.Success(users)
    }
}

// 错误：忘记处理异常
viewModelScope.launch {
    val users = api.getUsers()  // 可能抛出异常
}

// 正确：捕获异常
viewModelScope.launch {
    try {
        val users = api.getUsers()
        _state.value = UserState.Success(users)
    } catch (e: Exception) {
        _state.value = UserState.Error(e.message)
    }
}

// 错误：使用 suspend 函数但没有启动协程
class MyViewModel : ViewModel() {
    fun loadData() {
        suspendFun()  // 错误：suspend 函数不能在非协程上下文中调用
    }
}
```