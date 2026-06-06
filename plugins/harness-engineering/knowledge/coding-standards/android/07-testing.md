# Android 测试规范

## 1. 测试框架

使用 JUnit 5 + MockK + Turbine。

```kotlin
// build.gradle
dependencies {
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("app.cash.turbine:turbine:1.0.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
}
```

## 2. 单元测试

```kotlin
class UserViewModelTest {

    private lateinit var viewModel: UserViewModel
    private val getUsersUseCase = mockk<GetUsersUseCase>()

    @Before
    fun setup() {
        viewModel = UserViewModel(getUsersUseCase)
    }

    @Test
    fun `loadUsers success`() = runTest {
        // Arrange
        val users = listOf(User(1, "Alice"), User(2, "Bob"))
        coEvery { getUsersUseCase() } returns users

        // Act
        viewModel.loadUsers()
        advanceUntilIdle()

        // Assert
        assert(viewModel.uiState.value is UiState.Success)
        assert((viewModel.uiState.value as UiState.Success).users == users)
    }

    @Test
    fun `loadUsers error`() = runTest {
        // Arrange
        val error = Exception("Network error")
        coEvery { getUsersUseCase() } throws error

        // Act
        viewModel.loadUsers()
        advanceUntilIdle()

        // Assert
        assert(viewModel.uiState.value is UiState.Error)
    }
}
```

## 3. Flow 测试

```kotlin
@Test
fun `users state flow`() = runTest {
    val users = listOf(User(1, "Alice"), User(2, "Bob"))
    every { repository.getUsers() } returns flow { emit(users) }

    viewModel.loadUsers()

    turbine.test {
        awaitItem() // Loading
        awaitItem() // Success(users)
        cancelAndIgnoreRemaining()
    }
}

// 使用 Turbine
turbine.test {
    viewModel.uiState.test("loading") {
        assertEquals(UiState.Loading, awaitItem())
    }
    viewModel.loadUsers()
    test("success") {
        assertEquals(UiState.Success(users), awaitItem())
    }
}
```

## 4. Mock 使用

```kotlin
// Mock 函数
val mockRepository = mockk<UserRepository>()
coEvery { mockRepository.getUsers() } returns listOf(User(1, "Alice"))

// Mock 抛出异常
coEvery { mockRepository.getUserById(-1) } throws IllegalArgumentException("Invalid ID")

// Mock 延迟响应
coEvery { mockRepository.getUsers() } coAnswers {
    delay(1000)
    listOf(User(1, "Alice"))
}

// 验证调用
coVerify(exactly = 1) { mockRepository.getUsers() }
coVerify(atLeast = 1) { mockRepository.saveUser(any()) }
coVerify(atMost = 3) { mockRepository.deleteUser(any()) }

// 验证没有调用
verify(exactly = 0) { mockRepository.saveUser(any()) }

// 捕获参数
val slot = slot<User>()
coEvery { mockRepository.saveUser(capture(slot)) } returns Unit

viewModel.saveUser(User(1, "Alice"))
assert(slot.captured.name == "Alice")
```

## 5. 集成测试

```kotlin
// 使用 Hilt 测试
@HiltAndroidTest
class UserRepositoryTest {

    @Inject
    lateinit var userRepository: UserRepository

    @Test
    fun `save and retrieve user`() = runTest {
        val user = User(1, "Alice", "alice@example.com")

        userRepository.saveUser(user)
        val retrieved = userRepository.getUserById(1)

        assert(retrieved?.name == "Alice")
    }
}

// Database Testing
@Test
@Config(databaseImpl = SQLiteOpenHelper::class)
class UserDaoTest {

    @Test
    fun `insert and query user`() {
        val user = UserEntity(1, "Alice", "alice@example.com")
        userDao.insert(user)

        val result = userDao.queryById(1)
        assertEquals("Alice", result?.name)
    }
}
```

## 6. UI 测试

```kotlin
// 使用 Espresso
@Test
fun testUserListDisplayed() {
    launchFragment<UserListFragment>()

    onView(withId(R.id.tv_title))
        .check(matches(withText("Users")))

    onView(withId(R.id.recycler_view))
        .check(matches(hasChildCount(2)))
}

@Test
fun testUserClick() {
    launchFragment<UserListFragment>()

    onView(withText("Alice"))
        .perform(click())

    intended(hasComponent(UserDetailActivity::class.java))
    intended(hasExtra("userId", 1))
}

// Compose 测试
@Test
fun testUserCardDisplaysName() {
    composeTestRule.setContent {
        UserCard(user = User("Alice", "alice@example.com"))
    }

    onNodeWithText("Alice").assertIsDisplayed()
}
```

## 7. 测试覆盖率

```bash
# 运行测试并生成覆盖率
./gradlew testDebugUnitTest coverage

# 查看报告
open app/build/reports/coverage/debug/index.html
```

## 8. 测试原则

- 测试应该独立，不依赖其他测试
- 每个测试只验证一个概念
- 使用清晰有意义的测试名称
- 保持测试快速
- 测试边界条件
- AAA 模式（Arrange-Act-Assert）