# iOS 自动布局规范

## 1. 使用 SnapKit

```swift
import SnapKit

class UserView: UIView {

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(nameLabel)
        addSubview(emailLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
}
```

## 2. 布局规范

```swift
// 间距常量
private enum Layout {
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    static let cornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 48
}

// 使用常量
nameLabel.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(Layout.paddingMedium)
    make.leading.trailing.equalToSuperview().inset(Layout.paddingMedium)
}
```

## 3. 安全的约束

```swift
// 使用 safe area
nameLabel.snp.makeConstraints { make in
    make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
    make.leading.trailing.equalToSuperview().inset(16)
}

// 使用 readable content guide
bodyLabel.snp.makeConstraints { make in
    make.leading.trailing.equalTo(view.readableContentGuide)
}

// 使用 keyboard layout guide
textField.snp.makeConstraints { make in
    make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
}
```

## 4. 动态高度

```swift
// UITableView 自动高度
func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

// UICollectionView 流式布局
class FlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // 自定义布局
    }
}

// 使用 UITableView.automaticDimension
tableView.rowHeight = UITableView.automaticDimension
tableView.estimatedRowHeight = 100
```

## 5. Stack View

```swift
// 水平 Stack
private lazy var buttonStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
    stack.axis = .horizontal
    stack.spacing = 16
    stack.distribution = .fillEqually
    return stack
}()

// 垂直 Stack
private lazy var formStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [nameField, emailField, phoneField])
    stack.axis = .vertical
    stack.spacing = 12
    stack.alignment = .fill
    return stack
}()

// Stack View 布局
cancelButton.snp.makeConstraints { make in
    make.height.equalTo(Layout.buttonHeight)
}
confirmButton.snp.makeConstraints { make in
    make.height.equalTo(Layout.buttonHeight)
}
```

## 6. 约束优先级

```swift
// 优先级
nameLabel.snp.makeConstraints { make in
    make.leading.equalToSuperview().priority(.high)
    make.leading.greaterThanOrEqualToSuperview().offset(16).priority(.medium)
}

// 压缩阻力
nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
emailLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

// 压缩阻力
bodyLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
```

## 7. 动画约束

```swift
// 动画更新约束
private var isExpanded = false

private func toggle() {
    isExpanded.toggle()

    UIView.animate(withDuration: 0.3) {
        self.detailLabel.snp.updateConstraints { make in
            make.height.equalTo(self.isExpanded ? 100 : 0)
        }
        self.view.layoutIfNeeded()
    }
}

// 使用 SF Symbols
let chevronImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "chevron.down")
    imageView.tintColor = .secondaryLabel
    imageView.contentMode = .scaleAspectFit
    return imageView
}()
```

## 8. 常见布局模式

```swift
// 居中
centerView.snp.makeConstraints { make in
    make.center.equalToSuperview()
    make.width.equalTo(200)
}

// 填充
fullView.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}

// 边距
paddedView.snp.makeConstraints { make in
    make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
}

// 固定宽高
fixedView.snp.makeConstraints { make in
    make.width.equalTo(100)
    make.height.equalTo(50)
}
```

## 9. 避免约束警告

```swift
// 使用最新的 SnapKit API
view.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}

// 避免冲突
view1.snp.makeConstraints { make in
    make.edges.equalToSuperview()
}

view2.snp.makeConstraints { make in
    make.edges.equalTo(view1)
}

// 使用 prepareForInterfaceBuilder
@IBOutlet weak var cardView: UIView!

override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    setupConstraints()
}
```