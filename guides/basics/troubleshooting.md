---
title: OpenAI 兼容 API 报错排查：401、403、404、429、5xx 与 Base URL /v1 问题
description: 按状态码定位 OpenAI 兼容 API 报错：Key 无效、余额不足、模型不存在、/v1 重复、并发超限、服务繁忙、流式中断，附实测报错原文和 30 秒自查清单。
last_verified: 2026-10-08
---

# 通用排错手册：按状态码对号入座

> 最后实测：2026-10-08

[← 返回目录](../../README.md)

> [!NOTE]
> 本文报错原文来自 [MolyEye](https://molyeye.com/?ref=github) 实测。其它 OpenAI 兼容服务的状态码含义基本相同，原文措辞会不一样。

**一句话：** 先看状态码和报错原文，再动手。别一报错就重建 Key、重装软件，大部分问题是地址、Key、模型名三者之一填错了。

## 1. 30 秒自查

1. Key 用复制图标复制，没漏字、前后没多空格或引号。
2. Base URL 是 `https://api.molyeye.com/v1`，`/v1` 只出现一次，后面没跟 `/chat/completions`。
3. 模型 ID 和 [模型广场](https://molyeye.com/pricing) 一字不差（大小写、点、横杠）。
4. 账户余额大于 0。
5. 改完配置，把软件**完全退出**再打开（很多客户端不会热加载配置）。
6. 控制台 **使用日志** 里有没有这次请求。没有，说明请求根本没到服务端，问题在本地配置或网络。

## 2. 按状态码查

同一个错误，报错语言跟着客户端走：浏览器和中文客户端通常收到中文提示，SDK 和命令行工具通常收到英文。下面两种都列出来。

### 401：Key 不对

```text
API Key 无效：请检查是否复制完整（控制台 → API 密钥）
Invalid API key: check that it was copied completely (Console → API Keys)
```

- Key 没复制完整，或前后多了空格、换行、引号。
- 自己写代码的：请求头要写成 `Authorization: Bearer sk-...`，`Bearer` 后面有一个空格。漏了请求头也是这个报错。
- 用环境变量的：确认变量真的读到了（设完 `setx` 要重开终端）。
- Key 被删除或停用了：回控制台看一眼状态。

### 403：额度问题

- 账户余额用完了：去钱包充值，充完马上恢复，**不用重建 Key**。
- 这把 Key 单独设了额度上限或有效期，到了：编辑 Key 放开。

### 404：模型名或地址不对

**模型名写错**：

```text
模型 GPT-5.5 不存在或暂不可用，可用模型见 https://molyeye.com/pricing
Model GPT-5.5 does not exist or is temporarily unavailable. See available models at https://molyeye.com/pricing
```

照模型广场复制，`gpt-5.5` 不能写成 `GPT-5.5` 或 `gpt5.5`。名字确认没错还报这个，说明模型在维护，看 [服务状态](https://molyeye.com/help/status.html)。

**地址多写了一层 `/v1`**：

```text
Invalid URL (POST /v1/v1/chat/completions)
```

**地址少了 `/v1`**：请求打到 `https://api.molyeye.com/chat/completions`，同样返回 404。

### 429：请求太多

同时在跑的请求超过上限。按量余额的账号同时最多 7 个请求（余额低于 $10 时为 2 个）；有时长卡的按卡上写的数量。处理：

- 调低软件里的并发数（批量翻译、编程助手这类工具很常见）。
- 等前面的请求完成，或等几十秒再试。

### 502 / 503 / 504、超时

服务端临时繁忙。等一两分钟重试；连续失败看 [服务状态](https://molyeye.com/help/status.html)。

### 流式输出中途断了

开了 `stream: true` 时，偶尔会在输出到一半时收到一个带 `error` 的数据块，然后结束。这是临时故障，直接重试即可。自己写代码的，建议对这种情况自动重试一两次。

## 3. 「Base URL 要不要带 /v1」

不同软件拼地址的方式不一样，这是很常见的坑：

| 软件类型 | 填法 |
|---|---|
| OpenAI 官方 SDK（Python / Node） | `https://api.molyeye.com/v1` |
| Codex CLI（`config.toml` 的 `base_url`） | `https://api.molyeye.com/v1` |
| curl / 自己拼完整地址 | `https://api.molyeye.com/v1/chat/completions` |
| 会自动补 `/v1` 的客户端 | `https://api.molyeye.com`，以那个软件的教程为准 |

判断方法：报错里的路径如果是 `/v1/v1/...`，就去掉一层；如果是 `/chat/completions` 前面没有 `/v1`，就加上。

## 4. 其它常见问题

**PowerShell 里报「找不到接受实际参数」或「无法将 -H 项识别为 cmdlet」**
把 macOS / Linux 版的 curl 命令粘进了 Windows PowerShell。PowerShell 里的 `curl` 是另一个命令，也不认 `\` 换行。用 [快速开始](./quickstart.md) 里的 PowerShell 写法。

**问模型「你是哪个版本」，它答得不对**
正常。模型自报的版本不可靠，各家模型都常答错。以响应 JSON 里的 `model` 字段和控制台使用日志里记录的模型为准。

**一直转圈、很久才出第一个字**
推理类模型会先思考再输出。急用就换一个更快的模型，或开流式输出看进度。

**输出 token 比回答字数多很多**
推理类模型的思考过程也计入输出 token。每一笔的实际用量和扣费都在使用日志里逐条可查。

## 5. 还是不行

带上这三样去问客服：**报错原文**（含 request id）、**发生时间**、**模型名**。不要把 Key 发给任何人，客服也不需要它。
