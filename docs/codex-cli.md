# Codex CLI 接入中转站：config.toml 自定义 base_url 怎么写

> OpenAI 的终端编程助手，走 OpenAI Responses 接口。base_url 必须带 /api/v1；新版本要在 ~/.codex/config.toml 里配置。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| base_url | `https://www.ccsub.net/api/v1` | 必须带 /api/v1 |
| OPENAI_API_KEY | `sk-你的CCSub密钥` |  |
| model | `gpt-5.5` | 启动后可用 /model 切换 |

**~/.codex/config.toml（Windows：%USERPROFILE%\.codex\config.toml）**

```toml
model = "gpt-5.5"
model_provider = "ccsub"

[model_providers.ccsub]
name = "CCSub"
base_url = "https://www.ccsub.net/api/v1"
wire_api = "responses"
env_key = "OPENAI_API_KEY"
```

## 配置步骤

1. **安装 Codex CLI**：安装 Node.js 18 以上版本后执行 npm install -g @openai/codex@latest（macOS / Linux 需要 sudo），用 codex --version 查看版本号。
2. **创建 CCSub API Key**：注册 CCSub，在控制台「API 密钥」页面创建密钥并复制 sk- 开头的 Key。
3. **把 Key 写进 OPENAI_API_KEY**：macOS / Linux 在 ~/.zshrc 里加 export OPENAI_API_KEY="sk-你的密钥"，Windows 用 PowerShell 写入用户环境变量，然后重开终端。
4. **写 ~/.codex/config.toml**：新建或编辑 ~/.codex/config.toml，添加 model_providers.ccsub：base_url 为 https://www.ccsub.net/api/v1，wire_api 为 responses，env_key 为 OPENAI_API_KEY，并把 model_provider 设为 ccsub。
5. **启动并验证**：在项目目录执行 codex，发一句话确认有回复，再到 CCSub「使用记录」里核对这次请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `404 Not Found` | base_url 路径写错，例如多写了一层（/api/v1/v1）或者只写了 /api。 | base_url 改成 https://www.ccsub.net/api/v1。它和 Claude Code 的写法不一样，不要混用。 |
| `401 authentication_error: Missing or invalid API key` | env_key 指向的环境变量没设置，或者 Codex 是从桌面图标启动的、读不到终端里的变量。 | 在终端执行 echo $OPENAI_API_KEY 确认有值，从同一个终端启动 codex。 |
| `wire_api = "chat" is no longer supported` | 沿用了旧教程里的 wire_api = "chat"，新版 Codex 只支持 Responses 接口。 | 改成 wire_api = "responses"，CCSub 提供 /api/v1/responses。 |
| `改了 config.toml 但 model 设置没生效` | model、model_provider 这些顶层键写在了 [model_providers.ccsub] 下面，被当成了这个表的字段。 | 把顶层键移到文件最上方，放在第一个 [表] 之前。 |
| `402 insufficient_balance：余额不足` | 余额不够本次请求的预估费用，或月卡当天额度已用完。 | 到 [ccsub.net/zh/purchase](https://www.ccsub.net/zh/purchase?utm_source=github-guide) 充值；月卡额度在北京时间 0 点重置，用完后改扣余额。 |

## 常见问题

**OPENAI_BASE_URL 环境变量为什么不生效了？**

Codex 从 0.119 版本起不再读取 OPENAI_BASE_URL（0.118 会提示已弃用）。用 codex --version 看版本，新版本请改用 ~/.codex/config.toml 里的 model_providers 配置。

**base_url 是 /v1 还是 /api/v1？**

按 CCSub 文档统一写 https://www.ccsub.net/api/v1，Codex 会在后面拼 /responses。最常见的 404 是路径多写或少写了一段，例如 /api/v1/v1 或只写了 /api。

**启动 Codex 还是让我登录 ChatGPT 账号？**

说明 Codex 还在用内置的 openai 提供方。按本文写一个自定义提供方并设置 model_provider = "ccsub"，自定义提供方从 env_key 指定的环境变量读 Key，不会弹登录界面。

**项目目录里的 .codex/config.toml 能配置 CCSub 吗？**

不能。按 Codex 官方文档，项目级 config.toml 里的 model_provider、model_providers 和 openai_base_url 会被忽略，必须写在用户目录的 ~/.codex/config.toml。

**model 应该填什么？**

model 可填 gpt-5.5 等，全部可用型号 ID 见 CCSub 型号列表页。改 config.toml 里的 model，或者在 Codex 里用 /model 切换。

---

完整教程（更多写法和说明）：[Codex CLI 接入 CCSub：config.toml 和 OPENAI_BASE_URL 怎么写](https://www.ccsub.net/zh/integrations/codex-cli?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
