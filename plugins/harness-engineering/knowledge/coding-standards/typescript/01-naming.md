# TypeScript 命名规范

## 1. 通用规则

- 使用有意义的英文命名
- 变量和函数使用 camelCase
- 类型和接口使用 PascalCase
- 常量使用 UPPER_SNAKE_CASE
- 文件名使用 kebab-case（组件文件除外）

## 2. 变量命名

```typescript
// 普通变量
let userName: string = '张三';
let pageSize: number = 20;
let isDeleted: boolean = false;

// 集合变量
let userList: User[] = [];
let userMap: Map<string, User> = new Map();

// 布尔变量
let isActive: boolean = true;
let hasPermission: boolean = false;
let canEdit: boolean = true;

// 使用有意义的前缀
let loadingUsers: boolean = true;
let errorMessage: string | null = null;
```

## 3. 函数命名

```typescript
// 使用动词或动词短语
function getUserById(id: number): Promise<User> { ... }
function createUser(user: CreateUserDto): Promise<User> { ... }
function calculateTotal(items: Item[]): number { ... }
function isValidEmail(email: string): boolean { ... }

// 事件处理函数
function handleClick(event: React.MouseEvent): void { ... }
function handleChange(event: React.ChangeEvent<HTMLInputElement>): void { ... }
function handleSubmit(formData: FormData): void { ... }

// 回调函数
function onUserCreated(user: User): void { ... }
function onError(error: Error): void { ... }
```

## 4. 类型命名

```typescript
// 接口
interface User {
  id: number;
  name: string;
  email: string;
}

// 类型别名
type UserId = number;
type UserMap = Map<UserId, User>;
type ApiResponse<T> = {
  data: T;
  code: number;
  message: string;
};

// 枚举
enum UserStatus {
  Active = 'active',
  Inactive = 'inactive',
  Deleted = 'deleted',
}

// React 组件类型
type ButtonProps = {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
};

type ContainerProps = {
  children: React.ReactNode;
  className?: string;
};
```

## 5. 文件命名

```
// React 组件文件 - PascalCase
UserProfile.tsx
OrderList.tsx
ModalDialog.tsx

// 普通 TypeScript 文件 - kebab-case
user-service.ts
api-client.ts
utils-helper.ts
constants.ts

// 类型定义文件
types/user.ts
types/order.ts
```

## 6. React 组件命名

```typescript
// 组件名称 - PascalCase
export function UserProfile() { ... }
export class UserCard extends React.Component { ... }

// 组件文件
UserProfile.tsx
UserCard.tsx

// 样式文件（CSS Modules）
UserProfile.module.css
```

## 7. 命名禁忌

- 避免使用无意义命名如 data、temp、tmp
- 避免使用单字母（循环变量除外：i, j, k）
- 避免使用中文拼音
- 避免在变量名前加类型前缀（如 strName、numAge）
- 避免过度缩写（如usr、usrName）