---
title: Python 调用 OpenAI 兼容 API：openai 库设置 base_url、流式输出与 Responses 接口
description: 用官方 openai Python 库接入 OpenAI 兼容 API，改 base_url 和 api_key 两个参数即可；含普通对话、流式输出、Responses 接口示例和常见报错。
last_verified: 2026-10-08
---

# Python 接入：openai 库改两个参数

> 最后实测：2026-10-08 · Python 3.11.9 · openai 3.26.0 · 预计用时 5 分钟

[← 返回目录](../../README.md)

> [!NOTE]
> 本文用 [MolyEye](https://molyeye.com/?ref=github) 演示，新账号注册送 $0.3 体验额度。还没有 Key 的先看 [快速开始](../basics/quickstart.md)。

**一句话：** 用 OpenAI 官方的 `openai` 库，创建客户端时把 `base_url` 换成 `https://api.molyeye.com/v1`、`api_key` 换成你的 Key，其它代码一行不用改。

## 1. 前提

- Python 3（本文实测 3.11.9，openai 库版本要求以 PyPI 页面为准）
- 一把 API Key（控制台 → API 密钥）
- 一个模型 ID，例如 `gpt-5.5`（完整列表见 [模型广场](https://molyeye.com/pricing)）

## 2. 安装和配置

```bash
pip install openai
```

Key 放环境变量里，别写死在代码中（尤其是要提交到 Git 的代码）：

```bash
# macOS / Linux
export MOLYEYE_API_KEY="sk-你的Key"
```

```powershell
# Windows PowerShell（当前窗口有效）
$env:MOLYEYE_API_KEY = "sk-你的Key"
# 想永久生效：setx MOLYEYE_API_KEY "sk-你的Key"，然后重开终端
```

## 3. 普通对话

[`examples/python/chat.py`](../../examples/python/chat.py)：

```python
import os

from openai import OpenAI

client = OpenAI(
    base_url="https://api.molyeye.com/v1",
    api_key=os.environ["MOLYEYE_API_KEY"],
)

resp = client.chat.completions.create(
    model="gpt-5.5",
    messages=[{"role": "user", "content": "用一句话介绍你自己"}],
)
print(resp.choices[0].message.content)
print("实际模型：", resp.model, "| 用量：", resp.usage.total_tokens, "tokens")
```

实测输出：

```text
我是一个由 OpenAI 训练的人工智能助手，可以帮助你解答问题、编写代码、分析信息和完成各种文本任务。
实际模型： gpt-5.5 | 用量： 57 tokens
```

## 4. 流式输出

加 `stream=True`，边生成边打印。适合聊天界面和长回答。见 [`examples/python/stream.py`](../../examples/python/stream.py)：

```python
stream = client.chat.completions.create(
    model="gpt-5.5",
    messages=[{"role": "user", "content": "从 1 数到 5，每个数字一行"}],
    stream=True,
)
for chunk in stream:
    if chunk.choices and chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()
```

> 判断 `chunk.choices` 非空再取内容，有的数据块不带 choices，直接取 `[0]` 会报 IndexError。

## 5. Responses 接口

新版 openai 库也支持 Responses 接口，写法更短。见 [`examples/python/responses.py`](../../examples/python/responses.py)：

```python
resp = client.responses.create(
    model="gpt-5.5",
    input="用一句话介绍你自己",
)
print(resp.output_text)
```

实测输出：

```text
我是一个由 OpenAI 训练的 AI 助手，能够帮助你解答问题、编写和调试代码、整理信息并完成各种文字任务。
```

## 6. 也可以只用环境变量

openai 库会自动读 `OPENAI_BASE_URL` 和 `OPENAI_API_KEY`。用这种方式时，现成的项目不改代码也能切换：

```bash
export OPENAI_BASE_URL="https://api.molyeye.com/v1"
export OPENAI_API_KEY="sk-你的Key"
```

```python
from openai import OpenAI
client = OpenAI()  # 自动读取上面两个环境变量
```

## 7. 验证

- 输出里的「实际模型」和你请求的一致。
- 控制台 **使用日志** 里能看到这一笔调用和扣费。

## 8. 常见报错

以下报错原文均为 2026-10-08 实测（SDK 默认收到英文提示）。

| 报错 | 原因和处理 |
|---|---|
| `openai.AuthenticationError: Error code: 401` · `Invalid API key` | Key 不对或没读到环境变量。`print(os.environ.get("MOLYEYE_API_KEY", "")[:6])` 看看是不是 `sk-` 开头 |
| `KeyError: 'MOLYEYE_API_KEY'` | 环境变量没设置，或设置后没重开终端 / IDE |
| `openai.NotFoundError: Error code: 404` · `Model xxx does not exist or is temporarily unavailable` | 模型 ID 写错，照模型广场一字不差地复制 |
| `openai.NotFoundError: Error code: 404` · `Invalid URL (POST /v1/v1/chat/completions)` | `base_url` 写成了 `.../v1/v1` 或 `.../v1/chat/completions`，只写到 `/v1` |
| `openai.RateLimitError: Error code: 429` | 并发太高，降低并发或稍等再试 |
| `AttributeError: 'OpenAI' object has no attribute 'responses'` | openai 库版本太旧，`pip install -U openai` |

更多见 [通用排错手册](../basics/troubleshooting.md)。
