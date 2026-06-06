# Android 组件规范

## 1. Activity

```kotlin
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    private val viewModel: MainViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setupViews()
        observeState()
    }

    private fun setupViews() {
        binding.button.setOnClickListener {
            viewModel.onButtonClick()
        }
    }

    private fun observeState() {
        lifecycleScope.launch {
            viewModel.uiState.collect { state ->
                updateUi(state)
            }
        }
    }
}
```

## 2. Fragment

```kotlin
@AndroidEntryPoint
class UserListFragment : Fragment() {

    private var _binding: FragmentUserListBinding? = null
    private val binding get() = _binding!!

    private val viewModel: UserListViewModel by viewModels()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentUserListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        observeState()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }
}
```

## 3. ViewModel

```kotlin
@HiltViewModel
class UserListViewModel @Inject constructor(
    private val getUsersUseCase: GetUsersUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<UserListUiState>(UserListUiState.Idle)
    val uiState: StateFlow<UserListUiState> = _uiState.asStateFlow()

    // UI Event
    private val _events = MutableSharedFlow<UserListEvent>()
    val events: SharedFlow<UserListEvent> = _events.asSharedFlow()

    fun loadUsers() {
        viewModelScope.launch {
            _uiState.value = UserListUiState.Loading
            getUsersUseCase().fold(
                onSuccess = { users ->
                    _uiState.value = UserListUiState.Success(users)
                },
                onFailure = { error ->
                    _uiState.value = UserListUiState.Error(error.message ?: "Unknown error")
                }
            )
        }
    }

    fun onUserClicked(user: User) {
        viewModelScope.launch {
            _events.emit(UserListEvent.NavigateToDetail(user.id))
        }
    }
}

// UI State
sealed class UserListUiState {
    data object Idle : UserListUiState()
    data object Loading : UserListUiState()
    data class Success(val users: List<User>) : UserListUiState()
    data class Error(val message: String) : UserListUiState()
}

// UI Event
sealed class UserListEvent {
    data class NavigateToDetail(val userId: Int) : UserListEvent()
    data class ShowSnackbar(val message: String) : UserListEvent()
}
```

## 4. RecyclerView Adapter

```kotlin
class UserListAdapter(
    private val onItemClick: (User) -> Unit
) : ListAdapter<User, UserViewHolder>(UserDiffCallback()) {

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

    inner class UserViewHolder(
        private val binding: ItemUserBinding
    ) : RecyclerView.ViewHolder(binding.root) {

        init {
            binding.root.setOnClickListener {
                val position = bindingAdapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
        }

        fun bind(user: User) {
            binding.tvName.text = user.name
            binding.tvEmail.text = user.email
        }
    }
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

## 5. 自定义 View

```kotlin
class CustomButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : AppCompatButton(context, attrs, defStyleAttr) {

    init {
        context.theme.obtainStyledAttributes(
            attrs,
            R.styleable.CustomButton,
            0, 0
        ).apply {
            try {
                val textColor = getColor(R.styleable.CustomButton_customTextColor, Color.BLACK)
                setTextColor(textColor)
            } finally {
                recycle()
            }
        }
    }
}
```

## 6. Compose 组件

```kotlin
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = user.name,
                style = MaterialTheme.typography.titleMedium
            )
            Text(
                text = user.email,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun UserList(
    users: List<User>,
    onUserClick: (User) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier,
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(users, key = { it.id }) { user ->
            UserCard(
                user = user,
                onClick = { onUserClick(user) }
            )
        }
    }
}
```

## 7. Dialog

```kotlin
class ConfirmDialog : DialogFragment() {

    private var onConfirm: (() -> Unit)? = null

    fun setOnConfirmListener(listener: () -> Unit) {
        onConfirm = listener
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        return AlertDialog.Builder(requireContext())
            .setTitle(R.string.confirm)
            .setMessage(R.string.confirm_message)
            .setPositiveButton(R.string.ok) { _, _ ->
                onConfirm?.invoke()
            }
            .setNegativeButton(R.string.cancel, null)
            .create()
    }
}
```