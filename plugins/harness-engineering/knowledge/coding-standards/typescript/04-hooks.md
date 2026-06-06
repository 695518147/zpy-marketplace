# React Hooks 规范

## 1. Hooks 基础规则

- 只能在函数组件或自定义 Hook 中使用
- 只能在组件顶层调用，不能在条件语句或循环中使用
- 自定义 Hook 必须以 `use` 开头

## 2. useState

```typescript
// 基础用法
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// 多个状态
const [name, setName] = useState('');
const [age, setAge] = useState(0);

// 函数式更新
setCount(prev => prev + 1);

// 对象状态
const [formData, setFormData] = useState({
  name: '',
  email: '',
  password: '',
});

function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
  setFormData(prev => ({
    ...prev,
    [e.target.name]: e.target.value,
  }));
}
```

## 3. useEffect

```typescript
// 基础用法
useEffect(() => {
  document.title = `Count: ${count}`;
}, [count]);

// 清理函数
useEffect(() => {
  const subscription = api.subscribe(handleData);
  return () => {
    subscription.unsubscribe();
  };
}, []);

// 条件执行
useEffect(() => {
  if (userId) {
    fetchUser(userId);
  }
}, [userId]);
```

## 4. useCallback 和 useMemo

```typescript
// useCallback - 缓存回调函数
interface CounterProps {
  onIncrement: () => void;
  onDecrement: () => void;
}

function Counter({ onIncrement, onDecrement }: CounterProps) {
  const handleIncrement = useCallback(() => {
    onIncrement();
  }, [onIncrement]);

  return (
    <div>
      <button onClick={handleIncrement}>+</button>
      <button onClick={onDecrement}>-</button>
    </div>
  );
}

// useMemo - 缓存计算结果
function UserStatistics({ users }: { users: User[] }) {
  const statistics = useMemo(() => {
    return {
      total: users.length,
      activeCount: users.filter(u => u.status === 'active').length,
      averageAge: users.reduce((sum, u) => sum + u.age, 0) / users.length,
    };
  }, [users]);

  return (
    <div>
      <div>Total: {statistics.total}</div>
      <div>Active: {statistics.activeCount}</div>
      <div>Average Age: {statistics.averageAge.toFixed(1)}</div>
    </div>
  );
}
```

## 5. useRef

```typescript
// DOM 引用
function TextInput() {
  const inputRef = useRef<HTMLInputElement>(null);

  function focusInput() {
    inputRef.current?.focus();
  }

  return (
    <div>
      <input ref={inputRef} type="text" />
      <button onClick={focusInput}>Focus</button>
    </div>
  );
}

// 存储可变值（不触发重新渲染）
function useInterval(callback: () => void, delay: number) {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    const id = setInterval(() => savedCallback.current(), delay);
    return () => clearInterval(id);
  }, [delay]);
}
```

## 6. 自定义 Hooks

```typescript
// useLocalStorage
function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    setStoredValue(prev => {
      const valueToStore = value instanceof Function ? value(prev) : value;
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
      return valueToStore;
    });
  }, [key]);

  return [storedValue, setValue] as const;
}

// useFetch
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      try {
        const response = await fetch(url);
        const json = await response.json();
        if (!cancelled) {
          setData(json);
        }
      } catch (e) {
        if (!cancelled) {
          setError(e as Error);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      cancelled = true;
    };
  }, [url]);

  return { data, loading, error };
}

// useDebounce
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
```

## 7. useReducer

```typescript
type State = {
  count: number;
  error: string | null;
};

type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setError'; error: string };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + 1 };
    case 'decrement':
      return { ...state, count: state.count - 1 };
    case 'setError':
      return { ...state, error: action.error };
    default:
      return state;
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, { count: 0, error: null });

  return (
    <div>
      <span>{state.count}</span>
      <button onClick={() => dispatch({ type: 'increment' })}>+</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>-</button>
      {state.error && <div>{state.error}</div>}
    </div>
  );
}
```

## 8. Hooks 注意事项

```typescript
// 不要在条件语句中使用 hooks
function Component() {
  // 错误
  if (condition) {
    const [value, setValue] = useState(0);
  }

  // 正确
  const [value, setValue] = useState(0);

  // 使用 useMemo/useCallback 优化依赖
  const handleClick = useCallback(() => {
    onAction(value);
  }, [value, onAction]);

  // 清理 effect 中的定时器/订阅
  useEffect(() => {
    const timer = setInterval(() => {
      setCount(prev => prev + 1);
    }, 1000);

    return () => clearInterval(timer);
  }, []);
}
```