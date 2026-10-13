---
title: Node.js 调用 OpenAI 兼容 API：openai 库设置 baseURL、流式输出与 Responses 接口
description: 用官方 openai npm 包接入 OpenAI 兼容 API，改 baseURL 和 apiKey 即可；含 ESM 示例、流式输出、Responses 接口和常见报错。
last_verified: 2026-10-08
---

# Node.js 接入：openai 包改两个参数

> 最后实测：2026-10-08 · Node.js v24.15.0 · openai 7.30.0 · 预计用时 5 分钟

[← 返回目录](../../README.md)

> [!NOTE]
> 本文用 [MolyEye](https://molyeye.com/?ref=github) 演示，新账号注册送 $0.3 体验额度。还没有 Key 的先看 [快速开始](../basics/quickstart.md)。

**一句话：** 用 OpenAI 官方的 `openai` npm 包，`new OpenAI()` 时把 `baseURL` 换成 `https://api.molyeye.com/v1`、`apiKey` 换成你的 Key。注意是 `baseURL`（URL 全大写），不是 Python 里的 `base_url`。

## 1. 前提

- Node.js（本文实测 v24.15.0，openai 包的版本要求以 npm 页面为准）
- 一把 API Key（控制台 → API 密钥）
- 一个模型 ID，例如 `gpt-5.5`（完整列表见 [模型广场](https://molyeye.com/pricing)）

## 2. 安装和配置

```bash
npm install openai
```

示例用 ESM 写法（`import` + 顶层 `await`），文件后缀用 `.mjs`，或者在 `package.json` 里加 `"type": "module"`。

Key 放环境变量：

```bash
# macOS / Linux
export MOLYEYE_API_KEY="sk-你的Key"
```

```powershell
# Windows PowerShell（当前窗口有效）
$env:MOLYEYE_API_KEY = "sk-你的Key"
```

## 3. 普通对话

[`examples/node/chat.mjs`](../../examples/node/chat.mjs)：

```js
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.molyeye.com/v1",
  apiKey: process.env.MOLYEYE_API_KEY,
});

const resp = await client.chat.completions.create({
  model: "gpt-5.5",
  messages: [{ role: "user", content: "用一句话介绍你自己" }],
});
console.log(resp.choices[0].message.content);
console.log("实际模型：", resp.model, "| 用量：", resp.usage.total_tokens, "tokens");
```

运行：

```bash
node chat.mjs
```

实测输出：

```text
我是一个由 OpenAI 训练的 AI 助手，可以帮助你解答问题、编写和调试代码、分析信息并完成各种文字任务。
实际模型： gpt-5.5 | 用量： 61 tokens
```

## 4. 流式输出

加 `stream: true`，用 `for await` 逐块读取。见 [`examples/node/stream.mjs`](../../examples/node/stream.mjs)：

```js
const stream = await client.chat.completions.create({
  model: "gpt-5.5",
  messages: [{ role: "user", content: "从 1 数到 5，每个数字一行" }],
  stream: true,
});
for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content ?? "");
}
process.stdout.write("\n");
```

## 5. Responses 接口

见 [`examples/node/responses.mjs`](../../examples/node/responses.mjs)：

```js
const resp = await client.responses.create({
  model: "gpt-5.5",
  input: "用一句话介绍你自己",
});
console.log(resp.output_text);
```

实测输出：

```text
我是一个由人工智能驱动的编程助手，能够帮助你解决技术问题、编写和优化代码。
```

## 6. 也可以只用环境变量

openai 包会自动读 `OPENAI_BASE_URL` 和 `OPENAI_API_KEY`，设好后 `new OpenAI()` 不用传参数：

```bash
export OPENAI_BASE_URL="https://api.molyeye.com/v1"
export OPENAI_API_KEY="sk-你的Key"
```

## 7. 验证

- 输出里的「实际模型」和你请求的一致。
- 控制台 **使用日志** 里能看到这一笔调用和扣费。

## 8. 常见报错

以下报错原文均为 2026-10-08 实测（SDK 默认收到英文提示）。

| 报错 | 原因和处理 |
|---|---|
| `AuthenticationError` `401` · `Invalid API key` | Key 不对：没复制完整、前后多了空格 |
| `OpenAIError: Missing credentials` | `process.env.MOLYEYE_API_KEY` 是 `undefined`：环境变量没设好，或设好后没重开终端 |
| `NotFoundError` `404` · `Model xxx does not exist or is temporarily unavailable` | 模型 ID 写错，照模型广场一字不差地复制 |
| `NotFoundError` `404` · `Invalid URL (POST /v1/v1/chat/completions)` | `baseURL` 末尾多写了一层 `/v1`，只写到 `/v1` |
| `Cannot use import statement outside a module` / `Failed to load the ES module` | 文件后缀改成 `.mjs`，或 `package.json` 加 `"type": "module"` |
| `429` | 并发太高，降低并发或稍等再试 |

更多见 [通用排错手册](../basics/troubleshooting.md)。
