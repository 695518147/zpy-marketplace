# TypeScript 安全规范

## 1. 输入验证

```typescript
// 使用 Zod 进行 schema 验证
import { z } from 'zod';

const UserSchema = z.object({
  name: z.string().min(2).max(50),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
});

function createUser(data: unknown) {
  const result = UserSchema.safeParse(data);
  if (!result.success) {
    throw new ValidationError(result.error);
  }
  return result.data;
}

// 类型守卫
function isUser(obj: unknown): obj is User {
  return (
    typeof obj === 'object' &&
    obj !== null &&
    'id' in obj &&
    'name' in obj &&
    typeof (obj as User).id === 'number'
  );
}
```

## 2. XSS 防护

```typescript
// React 自动转义，不使用 dangerouslySetInnerHTML
// 除非绝对必要且内容已净化

function SafeDisplay({ content }: { content: string }) {
  return <div>{content}</div>();  // 自动转义
}

// 如果必须使用 dangerouslySetInnerHTML
import DOMPurify from 'dompurify';

function UnsafeDisplay({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

// URL 过滤
function safeUrl(url: string): string {
  try {
    const parsed = new URL(url);
    if (['http:', 'https:'].includes(parsed.protocol)) {
      return url;
    }
  } catch {}
  return '#';
}
```

## 3. SQL 注入防护

```typescript
// 使用参数化查询
// 错误 - 不要拼接 SQL
const query = `SELECT * FROM users WHERE name = '${name}'`;

// 正确 - 使用参数化
const query = 'SELECT * FROM users WHERE name = $1';
await db.query(query, [name]);

// 使用 ORM（推荐）
const user = await userRepository.findOne({
  where: { name },
});
```

## 4. 依赖安全

```bash
# 使用 npm audit 检查漏洞
npm audit
npm audit fix

# 使用 Snyk
npx snyk test

# 锁定依赖版本
npm shrinkwrap
# 或使用 package-lock.json
```

## 5. 敏感数据处理

```typescript
// 环境变量
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY is required');
}

// 不要在日志中记录敏感信息
function logUserLogin(username: string, success: boolean) {
  logger.info('User login', { username, success });  // OK
  // 不要记录: { password }
}

// 数据脱敏
function maskCreditCard(cardNumber: string): string {
  return cardNumber.replace(/\d(?=\d{4})/g, '*');
}

function maskPhone(phone: string): string {
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}
```

## 6. CSRF 防护

```typescript
// React + CSRF Token
function csrfFetch(url: string, options: RequestInit = {}) {
  const token = getCsrfToken();
  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-CSRF-Token': token,
    },
  });
}

// SameSite Cookie
document.cookie = 'session=xxx; SameSite=Strict';
document.cookie = 'session=xxx; SameSite=Lax';  // POST 表单
```

## 7. 限流

```typescript
// 客户端限流
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function checkRateLimit(key: string, limit: number, windowMs: number): boolean {
  const now = Date.now();
  const record = rateLimitMap.get(key);

  if (!record || now > record.resetTime) {
    rateLimitMap.set(key, { count: 1, resetTime: now + windowMs });
    return true;
  }

  if (record.count >= limit) {
    return false;
  }

  record.count++;
  return true;
}

// 使用
if (!checkRateLimit(userId, 100, 60000)) {
  throw new Error('Rate limit exceeded');
}
```

## 8. 认证与授权

```typescript
// JWT 验证
import jwt from 'jsonwebtoken';

interface TokenPayload {
  userId: number;
  role: string;
}

function verifyToken(token: string): TokenPayload {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as TokenPayload;
    return decoded;
  } catch {
    throw new UnauthorizedError('Invalid token');
  }
}

// 角色检查装饰器
function requireRole(role: string) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const original = descriptor.value;
    descriptor.value = function (...args: any[]) {
      const user = getCurrentUser();
      if (user.role !== role) {
        throw new ForbiddenError('Insufficient permissions');
      }
      return original.apply(this, args);
    };
  };
}
```

## 9. 安全配置检查清单

- 使用 HTTPS
- 设置安全的 HTTP 头（Content-Security-Policy, X-Frame-Options）
- 禁用 XSS 保护（如果需要）
- 使用 SameSite Cookie
- 启用 CSRF 保护
- 限制请求大小
- 实现速率限制