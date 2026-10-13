---
title: Codex CLI 自定义 API 配置：config.toml 写 model_provider、base_url 与 wire_api
description: 在 Codex CLI 的 config.toml 里添加自定义 model_provider，填 base_url、env_key、wire_api = "responses"，用 OpenAI 兼容 API 驱动 Codex 读写代码；含实测输出和常见报错。
last_verified: 2026-10-08
---

# Codex CLI 接入自定义 API：一个 config.toml 搞定

> 最后实测：2026-10-08 · Codex CLI 0.154.0 · Windows 10 · 预计用时 10 分钟

[← 返回目录](../../README.md)

> [!NOTE]
> 本文用 [MolyEye](https://molyeye.com/?ref=github) 演示，新账号注册送 $0.3 体验额度。还没有 Key 的先看 [快速开始](../basics/quickstart.md)。

**一句话：** 在 `~/.codex/config.toml` 里加一个自定义 `model_provider`，`base_url` 填 `https://api.molyeye.com/v1`，`wire_api` 填 `"responses"`，Key 放进环境变量，Codex 就会通过这个地址读写你的代码。

## 1. 前提

- Node.js（用来装 Codex CLI）
- 一把 API Key（控制台 → API 密钥）
- 模型 ID，例如 `gpt-5.5`（完整列表见 [模型广场](https://molyeye.com/pricing)）

Codex CLI 走的是 **Responses 接口**（`/v1/responses`），不是 Chat Completions。实测 0.154.0 不写 `wire_api` 也默认走 responses，但老版本默认值不同，写上更稳。

## 2. 安装 Codex CLI

```bash
npm install -g @openai/codex
codex --version
```

本文实测版本输出 `codex-cli 0.154.0`。

## 3. 写配置文件

编辑 `~/.codex/config.toml`（Windows 是 `C:\Users\你的用户名\.codex\config.toml`），没有就新建：

```toml
model = "gpt-5.5"
model_provider = "molyeye"

[model_providers.molyeye]
name = "MolyEye"
base_url = "https://api.molyeye.com/v1"
env_key = "MOLYEYE_API_KEY"
wire_api = "responses"
```

几个字段的意思：

| 字段 | 说明 |
|---|---|
| `model` | 默认用哪个模型，照模型广场一字不差 |
| `model_provider` | 指向下面 `[model_providers.xxx]` 里的名字，两处要一致 |
| `base_url` | 带 `/v1`，Codex 会自己拼 `/responses` |
| `env_key` | 从哪个**环境变量**读 Key。这里写的是变量名，不是 Key 本身 |
| `wire_api` | 接口类型，写 `"responses"` |

> 已经有 `config.toml` 的，先备份一份再改。顶层的 `model` 和 `model_provider` 两行要放在所有 `[xxx]` 小节**前面**，放到小节下面会被当成小节里的字段。

## 4. 设置环境变量

```powershell
# Windows（PowerShell 或 CMD 都行），设完要重开终端
setx MOLYEYE_API_KEY "sk-你的Key"
```

```bash
# macOS / Linux：写进 ~/.zshrc 或 ~/.bashrc，然后 source 一下
export MOLYEYE_API_KEY="sk-你的Key"
```

## 5. 验证

重开终端，进入任意一个项目目录，先跑一条简单的：

```bash
codex exec "只回复：配置成功"
```

输出里出现 `配置成功`（后面跟一行 `tokens used` 和本次的 token 数）就说明通了。

加上 `--json` 能看到用量明细，实测一次是这样：

```text
{"type":"turn.completed","usage":{"input_tokens":11989,"cached_input_tokens":11520,...,"output_tokens":6,...}}
```

> `input_tokens` 有一万多，是因为 Codex 每次都会带上自己的系统提示和工具说明，不是你的问题写长了。`cached_input_tokens` 是命中缓存的部分，按缓存价计费。

再让它真的动一下文件：

```bash
codex exec "在当前目录新建 hello.py，内容是打印 hello，然后用 py 运行它并告诉我输出。只做这一件事。"
```

实测（节选，本机路径已省略）：

```text
model: gpt-5.5
provider: molyeye
--------
codex
我会在当前目录创建 `hello.py`，写入打印语句，然后执行并返回实际输出。
apply patch
patch: completed
+print("hello")
exec
 "...\pwsh.exe" -Command 'py hello.py' in <项目目录>
 succeeded in 663ms:
hello
codex
已创建并运行 `hello.py`。
```

看到 `provider: molyeye`、文件被创建并运行，说明配置全部生效。之后直接敲 `codex` 进入交互模式正常使用即可。控制台 **使用日志** 里能看到每一次请求的模型、token 和扣费。

## 6. 常见报错和提示

报错原文均为 2026-10-08 实测。

| 现象 | 原因和处理 |
|---|---|
| `ERROR: Missing environment variable: MOLYEYE_API_KEY` | 环境变量没设，或 `setx` 之后没重开终端 |
| `ERROR: Missing environment variable: sk-...` | `env_key` 里填成了 Key 本身。改回变量名 `MOLYEYE_API_KEY`，Key 放进环境变量 |
| 401 · `Invalid API key` | 环境变量里的 Key 不对：没复制完整、前后多了空格或引号 |
| 404 · 模型不存在或暂不可用 | `model` 写错，照模型广场复制 |
| 404 · `Invalid URL (POST /v1/v1/responses)` | `base_url` 末尾多写了一层 `/v1` |
| 提示 `Model metadata for xxx not found. Defaulting to fallback metadata` | Codex 内置表里没有这个模型名的元数据（上下文长度等），会用默认值，能正常对话。实测 `gpt-6-sol` 会出现这条提示，`gpt-5.5` 不会 |
| 在脚本里调用 `codex exec` 卡住不动，显示 `Reading additional input from stdin...` | 它在等标准输入。脚本里加 `< /dev/null`（Windows PowerShell 用 `$null \| codex exec ...`） |
| 让它改文件时提示 `writing is blocked by read-only sandbox` | `codex exec` 默认只读沙箱，和接口无关。交互模式里按提示批准，或看 Codex 官方文档的 `--sandbox` 参数说明 |
| 429 | 同时跑的请求太多，等前面的完成或稍等再试 |

更多见 [通用排错手册](../basics/troubleshooting.md)。
