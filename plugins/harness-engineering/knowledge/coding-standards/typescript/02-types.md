# TypeScript 类型规范

## 1. 基础类型注解

```typescript
// 基本类型
let name: string = '张三';
let age: number = 25;
let height: number = 1.75;
let isActive: boolean = true;

// 数组类型
let names: string[] = ['Alice', 'Bob'];
let users: Array<User> = [];
let ids: ReadonlyArray<number> = [1, 2, 3];

// 对象类型
let point: { x: number; y: number } = { x: 0, y: 0 };
```

## 2. 接口与类型别名

```typescript
// 接口 - 用于定义对象结构
interface User {
  id: number;
  name: string;
  email: string;
  age?: number;  // 可选属性
  readonly createdAt: Date;  // 只读属性
}

// 类型别名 - 用于复杂类型
type UserId = number;
type UserOrNull = User | null;
type UserList = User[];

// 联合类型
type Status = 'pending' | 'active' | 'deleted';
type Result = Success | Error;

// 交叉类型
type ExtendedUser = User & {
  phone: string;
  address: string;
};
```

## 3. 函数类型

```typescript
// 函数签名
type QueryFunction = (params: QueryParams) => Promise<Result>;
type ValidateFunction = (value: string) => boolean;

// 回调函数
type Callback = (error: Error | null, result: Result | null) => void;

// React 组件类型
type ComponentProps = {
  children: React.ReactNode;
};

type ClickHandler = (event: React.MouseEvent<HTMLButtonElement>) => void;
type ChangeHandler = (event: React.ChangeEvent<HTMLInputElement>) => void;
```

## 4. 泛型

```typescript
// 泛型接口
interface ApiResponse<T> {
  data: T;
  code: number;
  message: string;
}

interface Repository<T> {
  findById(id: number): Promise<T | null>;
  save(entity: T): Promise<T>;
  delete(id: number): Promise<void>;
}

// 泛型函数
function identity<T>(arg: T): T {
  return arg;
}

function map<T, U>(array: T[], fn: (item: T) => U): U[] {
  return array.map(fn);
}

// 泛型约束
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

## 5. Utility Types

```typescript
// 常用工具类型
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
}

// Partial - 所有属性可选
type PartialUser = Partial<User>;

// Required - 所有属性必需
type RequiredUser = Required<User>;

// Pick - 选择部分属性
type UserPreview = Pick<User, 'id' | 'name'>;

// Omit - 排除部分属性
type UserWithoutPassword = Omit<User, 'password'>;

// Record - 键值对
type UserMap = Record<string, User>;

// Exclude 和 Extract
type Status = 'pending' | 'active' | 'deleted';
type ActiveStatus = Extract<Status, 'active' | 'pending'>;
type NonDeletedStatus = Exclude<Status, 'deleted'>;
```

## 6. React Props 类型

```typescript
// 函数组件 Props
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary' | 'danger';
  disabled?: boolean;
  className?: string;
}

export function Button({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) {
  return (
    <button className={`btn btn-${variant}`} onClick={onClick} disabled={disabled}>
      {label}
    </button>
  );
}

// 状态组件 Props
interface CounterProps {
  initialCount: number;
  onChange: (count: number) => void;
}

// children 类型
interface CardProps {
  children: React.ReactNode;
  title?: string;
  footer?: React.ReactNode;
}
```

## 7. 类型守卫

```typescript
// 自定义类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj
  );
}

// instanceof 类型守卫
function processError(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return 'Unknown error';
}

// in 操作符
function getProperty(obj: User | Admin, key: string): unknown {
  if (key in obj) {
    return obj[key as keyof User | Admin];
  }
  return undefined;
}
```

## 8. 严格类型检查

```typescript
// tsconfig.json 建议配置
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}

// 使用 unknown 而不是 any
function parseJSON(json: string): unknown {
  return JSON.parse(json);
}

// 使用 never 防止意外值
function assertNever(x: never): never {
  throw new Error('Unexpected value: ' + x);
}
```