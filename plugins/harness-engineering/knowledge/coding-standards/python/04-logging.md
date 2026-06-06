# Python 日志规范

## 1. 日志配置

```python
import logging
from logging.handlers import RotatingFileHandler

# 配置日志
def setup_logging() -> None:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
        handlers=[
            logging.StreamHandler(),
            RotatingFileHandler("app.log", maxBytes=10*1024*1024, backupCount=5)
        ]
    )

logger = logging.getLogger(__name__)
```

## 2. 日志级别

| 级别 | 使用场景 |
|------|----------|
| `DEBUG` | 调试信息，开发环境使用 |
| `INFO` | 重要业务节点，正常流程 |
| `WARNING` | 警告信息，可能有问题 |
| `ERROR` | 错误，需要关注 |
| `CRITICAL` | 严重错误，系统故障 |

```python
logger.debug(f"Processing request: {request_id}")
logger.info(f"User created: user_id={user_id}")
logger.warning(f"Retry attempt {attempt} failed")
logger.error(f"Database error: {e}", exc_info=True)
logger.critical(f"System shutdown: {e}")
```

## 3. 日志格式化

```python
# 使用结构化日志
import json
from typing import Any

class JSONFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        log_data = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "extra": getattr(record, "extra", {})
        }
        return json.dumps(log_data)

# 记录结构化数据
logger.info("User action", extra={"user_id": 123, "action": "login"})
```

## 4. 日志记录最佳实践

```python
# 使用占位符而非字符串拼接
# 错误
logger.info(f"User {user_id} created")

# 正确
logger.info("User created: userId=%d", user_id)

# 记录上下文信息
logger.info("Processing order", extra={
    "order_id": order_id,
    "user_id": user_id,
    "amount": float(amount)
})

# 记录异常
try:
    process()
except Exception as e:
    logger.error("Process failed", exc_info=True)
```

## 5. 日志分类

```python
# 模块化日志
logger = logging.getLogger(__name__)  # 自动使用模块名
logger = logging.getLogger("user.service")
logger = logging.getLogger("order.controller")
```

## 6. 敏感信息处理

```python
# 不要记录敏感信息
logger.info(f"User login: username={username}")  # OK
logger.info(f"User login: password={password}")  # 禁止

# 使用掩码
def mask_password(password: str) -> str:
    return "*" * len(password)

# 审计日志
logger.info("Security event", extra={
    "event": "PASSWORD_CHANGE",
    "user_id": user_id,
    "ip": ip_address,
    "result": "SUCCESS"
})
```

## 7. 异步日志

```python
# 使用 queue 处理异步日志
from logging.handlers import QueueHandler, QueueListener

queue = queue.Queue()
handler = RotatingFileHandler("app.log")
listener = QueueListener(queue, handler)

# 应用中使用
logger = logging.getLogger("app")
logger.addHandler(QueueHandler(queue))
```

## 8. 日志配置YAML

```yaml
# logging.yaml
version: 1
disable_existing_loggers: false

formatters:
  standard:
    format: "%(asctime)s [%(levelname)s] %(name)s - %(message)s"
  json:
    class: app.utils.JSONFormatter

handlers:
  console:
    class: logging.StreamHandler
    formatter: standard
  file:
    class: logging.handlers.RotatingFileHandler
    filename: app.log
    maxBytes: 10485760
    backupCount: 5
    formatter: standard

root:
  level: INFO
  handlers: [console, file]

loggers:
  user.service:
    level: DEBUG
    handlers: [file]
    propagate: false
```