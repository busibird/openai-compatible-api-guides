---
title: OpenAI 兼容 API 快速开始：Base URL、API Key、模型 ID 三样填对就能用
description: 5 分钟拿到 API Key，用 curl 发出第一条请求，确认 Base URL、模型 ID 和计费都正常。适用于所有支持 OpenAI 兼容接口的软件和 SDK。
last_verified: 2026-10-08
---

# 快速开始：三样东西，跑通第一条请求

> 最后实测：2026-10-08 · 预计用时 5 分钟

[← 返回目录](../../README.md)

> [!NOTE]
> 本文用 [MolyEye](https://molyeye.com/?ref=github) 演示。新账号注册送 $0.3 体验额度，足够把本仓库的教程都跑一遍。其它 OpenAI 兼容服务换掉地址和 Key 也能照做。

**一句话：** 任何支持「OpenAI 兼容接口」的软件，都只要填三样东西：**Base URL**、**API Key**、**模型 ID**。

| 填什么 | 值 |
|---|---|
| Base URL | `https://api.molyeye.com/v1` |
| API Key | 控制台创建的 `sk-` 开头的一串 |
| 模型 ID | 例如 `gpt-5.5`，完整列表见 [模型广场](https://molyeye.com/pricing) |

## 1. 前提

- 一个能收验证码的邮箱（支持 QQ、Foxmail、163、126、Gmail、iCloud）
- 一个终端：macOS / Linux 自带；Windows 用 PowerShell 或 CMD

## 2. 拿到 API Key

1. 打开 [molyeye.com](https://molyeye.com/?ref=github)，右上角注册。
2. 登录后进入 **控制台 → API 密钥 → 创建 API 密钥**，名字随便起，其它保持默认。
3. 点 Key 旁边的复制图标。

> Key 就是密码，拿到它的人能直接花你的余额。不要发到群里、截图里或公开仓库里。

## 3. 发出第一条请求

先把 Key 放进环境变量，后面所有示例都从这里读：

```bash
# macOS / Linux
export MOLYEYE_API_KEY="sk-你的Key"
```

```powershell
# Windows PowerShell（只对当前窗口有效）
$env:MOLYEYE_API_KEY = "sk-你的Key"
```

**macOS / Linux：**

```bash
curl https://api.molyeye.com/v1/chat/completions \
  -H "Authorization: Bearer $MOLYEYE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-5.5","messages":[{"role":"user","content":"用一句话介绍你自己"}]}'
```

**Windows PowerShell：**

```powershell
$body = '{"model":"gpt-5.5","messages":[{"role":"user","content":"hello"}]}'
$r = Invoke-RestMethod -Method Post -Uri "https://api.molyeye.com/v1/chat/completions" `
  -Headers @{ Authorization = "Bearer $env:MOLYEYE_API_KEY" } `
  -ContentType "application/json; charset=utf-8" -Body $body
$r.choices[0].message.content
```

> PowerShell 里的 `curl` 是另一个命令，不认 `\` 换行，别把 macOS 那段直接贴进去。

## 4. 验证

成功时返回类似这样的 JSON（2026-10-08 实测原样输出，只截短了 id）：

```json
{
  "id": "chatcmpl-2026100806315246...",
  "object": "chat.completion",
  "created": 1791441136,
  "model": "gpt-5.5",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "我是一个乐于助人的 AI 助手，可以帮助你解答问题、编写代码和完成各种任务。"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 26,
    "completion_tokens": 159,
    "total_tokens": 185
  }
}
```

> `completion_tokens` 比回答字数多，是因为 gpt-5.5 这类推理模型会先「想」一会儿，思考用的 token 也计入输出。

再确认两件事：

- 返回里的 `model` 字段就是你请求的模型。
- 打开控制台 **使用日志**，能看到刚才这一笔：模型、token 数、扣了多少钱，逐笔可查。

想看当前 Key 能用哪些模型：

```bash
curl https://api.molyeye.com/v1/models -H "Authorization: Bearer $MOLYEYE_API_KEY"
```

## 5. 常见报错

| 现象 | 原因 |
|---|---|
| `401` · API Key 无效 | Key 没复制完整、前后多了空格，或请求头漏了 `Bearer ` |
| `404` · 模型 xxx 不存在或暂不可用 | 模型 ID 写错，要和模型广场一字不差（`gpt-5.5`，不是 `GPT-5.5`） |
| `404` · Invalid URL (POST /v1/v1/...) | Base URL 末尾的 `/v1` 写了两遍 |
| `429` | 同时发的请求太多，降低并发或稍等再试 |

更多见 [通用排错手册](./troubleshooting.md)。

## 下一步

- [Python 接入](../dev/python.md)
- [Node.js 接入](../dev/nodejs.md)
- [Codex CLI 配置](../coding-tools/codex-cli.md)
