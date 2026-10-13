# OpenAI 兼容 API 接入教程

各种软件和 SDK 怎么填 **Base URL、API Key、模型 ID**。每篇都用真实 Key 跑通后才写，标了实测日期和版本。

## 三样东西

| 填什么 | 值 |
|---|---|
| Base URL | `https://api.molyeye.com/v1` |
| API Key | 控制台 → API 密钥 → 创建 |
| 模型 ID | 例如 `gpt-5.5`，见 [模型广场](https://molyeye.com/pricing) |

教程用 [MolyEye](https://molyeye.com/?ref=github) 演示：**新账号注册送 $0.3 体验额度**，够把下面的教程都跑一遍；每个模型的单价在模型广场公开，每笔调用在使用日志里逐条可查。换成别的 OpenAI 兼容服务，改地址和 Key 也能照做。

## 按问题直达

| 你想解决 | 看这篇 |
|---|---|
| 第一次用，从哪开始 | [快速开始](guides/basics/quickstart.md) |
| Python 怎么设置 base_url | [Python](guides/dev/python.md) |
| Node.js 怎么设置 baseURL | [Node.js](guides/dev/nodejs.md) |
| Codex CLI 的 config.toml 怎么写 | [Codex CLI](guides/coding-tools/codex-cli.md) |
| VS Code 里的 Cline 怎么填 Base URL | [Cline](guides/coding-tools/cline.md) |
| Cherry Studio 怎么添加自定义服务商 | [Cherry Studio](guides/apps/cherry-studio.md) |
| 沉浸式翻译怎么用自己的 Key | [沉浸式翻译](guides/apps/immersive-translate.md) |
| 401 / 404 / 429 报错 | [通用排错手册](guides/basics/troubleshooting.md) |

## 教程目录

- **基础**：[快速开始](guides/basics/quickstart.md) · [通用排错手册](guides/basics/troubleshooting.md)
- **开发**：[Python](guides/dev/python.md) · [Node.js](guides/dev/nodejs.md)
- **编程工具**：[Codex CLI](guides/coding-tools/codex-cli.md) · [Cline](guides/coding-tools/cline.md)
- **客户端 / 扩展**：[Cherry Studio](guides/apps/cherry-studio.md) · [沉浸式翻译](guides/apps/immersive-translate.md)

能直接运行的示例代码在 [`examples/`](examples/)：Python、Node.js、curl 都有普通对话、流式、Responses 三种写法，curl 另附查模型列表。

## 说明

- Key 就是密码，别贴进 Issue、截图或公开代码里。
- 教程过时或跑不通，欢迎提 Issue，写清软件版本和报错原文。
- 文档采用 [MIT License](LICENSE)。
