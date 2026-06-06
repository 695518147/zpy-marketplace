# TypeScript 测试规范

## 1. 测试框架选择

使用 Jest + React Testing Library。

```bash
# 安装
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
npm install --save-dev ts-jest @types/jest
```

## 2. 单元测试

```typescript
// user.service.ts
export function calculateTotal(items: { price: number; quantity: number }[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// user.service.test.ts
import { calculateTotal } from './user.service';

describe('calculateTotal', () => {
  it('returns 0 for empty array', () => {
    expect(calculateTotal([])).toBe(0);
  });

  it('calculates total for single item', () => {
    expect(calculateTotal([{ price: 10, quantity: 2 }])).toBe(20);
  });

  it('calculates total for multiple items', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 20, quantity: 1 },
    ];
    expect(calculateTotal(items)).toBe(40);
  });
});
```

## 3. React 组件测试

```typescript
// UserCard.tsx
interface UserCardProps {
  name: string;
  email: string;
  onEdit: () => void;
}

export function UserCard({ name, email, onEdit }: UserCardProps) {
  return (
    <div>
      <h3>{name}</h3>
      <p>{email}</p>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

// UserCard.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  it('renders user information', () => {
    render(<UserCard name="Alice" email="alice@example.com" onEdit={jest.fn()} />);

    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
  });

  it('calls onEdit when button is clicked', () => {
    const handleEdit = jest.fn();
    render(<UserCard name="Alice" email="alice@example.com" onEdit={handleEdit} />);

    fireEvent.click(screen.getByText('Edit'));
    expect(handleEdit).toHaveBeenCalledTimes(1);
  });
});
```

## 4. Hooks 测试

```typescript
import { renderHook, act } from '@testing-library/react';
import { useCounter } from './useCounter';

describe('useCounter', () => {
  it('initializes with 0', () => {
    const { result } = renderHook(() => useCounter());
    expect(result.current.count).toBe(0);
  });

  it('increments', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements', () => {
    const { result } = renderHook(() => useCounter(10));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(9);
  });
});
```

## 5. Mock 使用

```typescript
// Mock 函数
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue({ id: 1, name: 'Alice' });

// Mock 模块
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'Alice' }),
}));

// Mock React 组件
jest.mock('./HeavyComponent', () => {
  return function DummyComponent() {
    return <div>Mocked</div>;
  };
});

// 模拟定时器
beforeEach(() => {
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});

it('debounces input', () => {
  const callback = jest.fn();
  const { getByLabelText } = render(<DebouncedInput onChange={callback} />);

  fireEvent.change(getByLabelText('input'), { target: { value: 'a' } });
  fireEvent.change(getByLabelText('input'), { target: { value: 'ab' } });

  jest.advanceTimersByTime(300);

  expect(callback).toHaveBeenCalledTimes(1);
});
```

## 6. 测试覆盖率

```bash
# 运行覆盖率
npm test -- --coverage

# 查看报告
npm test -- --coverage --coverageReporters=html

# jest.config.js
module.exports = {
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    '!src/**/*.d.ts',
    '!src/**/*.test.{ts,tsx}',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

## 7. 集成测试

```typescript
// setupTests.ts
import '@testing-library/jest-dom';

// App.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { rest } from 'msw';
import { setupServer } from 'msw/node';
import { App } from './App';

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(ctx.json([{ id: 1, name: 'Alice' }]));
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

it('loads and displays users', async () => {
  render(<App />);

  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument();
  });
});
```

## 8. 测试原则

- 每个测试应该只测试一个概念
- 测试应该独立，不依赖其他测试
- 使用 describe 组织相关测试
- 使用清晰的测试名称
- AAA 模式（Arrange-Act-Assert）
- 避免实现细节测试
- 优先测试关键业务逻辑