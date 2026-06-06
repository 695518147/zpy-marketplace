# React 组件规范

## 1. 组件结构

```typescript
// 组件文件结构
import React from 'react';
import styles from './UserCard.module.css';

// 类型定义
interface UserCardProps {
  user: User;
  onEdit: (user: User) => void;
  onDelete: (userId: number) => void;
}

// 组件定义
export function UserCard({ user, onEdit, onDelete }: UserCardProps) {
  // Hooks
  const [isExpanded, setIsExpanded] = React.useState(false);

  // 事件处理
  function handleEdit() {
    onEdit(user);
  }

  // 渲染
  return (
    <div className={styles.card}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <button onClick={handleEdit}>Edit</button>
      <button onClick={() => onDelete(user.id)}>Delete</button>
    </div>
  );
}
```

## 2. 组件分类

### 展示组件 (Presentational Components)

```typescript
// 纯展示组件，只负责渲染
interface UserAvatarProps {
  name: string;
  size?: 'small' | 'medium' | 'large';
}

export function UserAvatar({ name, size = 'medium' }: UserAvatarProps) {
  return (
    <div className={`avatar avatar-${size}`}>
      {name.charAt(0).toUpperCase()}
    </div>
  );
}
```

### 容器组件 (Container Components)

```typescript
// 负责数据获取和状态管理
interface UserListContainerProps {
  onSelectUser: (user: User) => void;
}

export function UserListContainer({ onSelectUser }: UserListContainerProps) {
  const [users, setUsers] = React.useState<User[]>([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    fetchUsers()
      .then(setUsers)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingSpinner />;

  return (
    <div>
      {users.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onEdit={onSelectUser}
        />
      ))}
    </div>
  );
}
```

## 3. 组件组合

```typescript
// 组合多个小组件
interface FormProps {
  onSubmit: (data: FormData) => void;
}

export function Form({ onSubmit }: FormProps) {
  return (
    <form>
      <FormInput name="username" label="Username" />
      <FormInput name="email" label="Email" type="email" />
      <FormButton type="submit">Submit</FormButton>
    </form>
  );
}

// 使用 Children
interface LayoutProps {
  header?: React.ReactNode;
  children: React.ReactNode;
  footer?: React.ReactNode;
}

export function Layout({ header, children, footer }: LayoutProps) {
  return (
    <div className="layout">
      {header && <header>{header}</header>}
      <main>{children}</main>
      {footer && <footer>{footer}</footer>}
    </div>
  );
}
```

## 4. 组件样式

```css
/* UserCard.module.css */
.card {
  padding: 16px;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.card h3 {
  margin: 0 0 8px;
  font-size: 18px;
}

.card p {
  color: #666;
}
```

## 5. 组件测试

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  const mockUser: User = {
    id: 1,
    name: 'Alice',
    email: 'alice@example.com',
  };

  it('renders user information', () => {
    render(
      <UserCard
        user={mockUser}
        onEdit={jest.fn()}
        onDelete={jest.fn()}
      />
    );

    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', () => {
    const handleEdit = jest.fn();
    render(
      <UserCard
        user={mockUser}
        onEdit={handleEdit}
        onDelete={jest.fn()}
      />
    );

    fireEvent.click(screen.getByText('Edit'));
    expect(handleEdit).toHaveBeenCalledWith(mockUser);
  });
});
```

## 6. 组件性能

```typescript
// 使用 React.memo 优化重渲染
interface UserListProps {
  users: User[];
  onSelect: (user: User) => void;
}

export const UserList = React.memo(function UserList({ users, onSelect }: UserListProps) {
  return (
    <div>
      {users.map(user => (
        <UserItem key={user.id} user={user} onSelect={onSelect} />
      ))}
    </div>
  );
});

// 使用 useMemo 缓存计算结果
function UserStatistics({ users }: { users: User[] }) {
  const statistics = React.useMemo(() => ({
    total: users.length,
    active: users.filter(u => u.status === 'active').length,
  }), [users]);

  return (
    <div>
      <span>Total: {statistics.total}</span>
      <span>Active: {statistics.active}</span>
    </div>
  );
}

// 使用 useCallback 缓存回调
interface ParentProps {
  onUserSelect: (user: User) => void;
}

export function Parent({ onUserSelect }: ParentProps) {
  const handleSelect = React.useCallback((user: User) => {
    onUserSelect(user);
  }, [onUserSelect]);

  return <UserList onSelect={handleSelect} />;
}
```

## 7. 组件文档

```typescript
/**
 * UserCard 组件用于展示用户信息卡片
 *
 * @param user - 用户对象
 * @param onEdit - 编辑回调
 * @param onDelete - 删除回调
 *
 * @example
 * ```tsx
 * <UserCard
 *   user={{ id: 1, name: 'Alice', email: 'alice@example.com' }}
 *   onEdit={(user) => console.log('Edit', user)}
 *   onDelete={(id) => console.log('Delete', id)}
 * />
 * ```
 */
export function UserCard({ user, onEdit, onDelete }: UserCardProps) {
  // ...
}
```