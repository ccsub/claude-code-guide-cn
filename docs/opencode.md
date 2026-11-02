# OpenCode 接入中转站：opencode.json 的 provider 和 baseURL 怎么写

> 开源的终端编程助手，Anthropic 和 OpenAI 两种协议都能接。在 opencode.json 里加一个自定义 provider 即可，注意 baseURL 要带 /v1。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| baseURL | `https://www.ccsub.net/api/v1` | 两种协议都填这个，必须带 /v1 |
| apiKey | `sk-你的CCSub密钥` | 也可以用 /connect 保存 |
| model | `ccsub/claude-sonnet-5` | 格式是 provider/型号 |

**~/.config/opencode/opencode.json（Anthropic 协议示例）**

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ccsub": {
      "npm": "@ai-sdk/anthropic",
      "name": "CCSub",
      "options": {
        "baseURL": "https://www.ccsub.net/api/v1",
        "apiKey": "{env:CCSUB_API_KEY}"
      },
      "models": {
        "claude-sonnet-5": { "name": "claude-sonnet-5" }
      }
    }
  },
  "model": "ccsub/claude-sonnet-5"
}
```

## 配置步骤

1. **安装 OpenCode 并创建 CCSub Key**：按 OpenCode 官网的方式安装，然后在 CCSub 控制台「API 密钥」页面创建一把 sk- 开头的 Key。
2. **把 Key 放进环境变量**：在 ~/.zshrc 里加 export CCSUB_API_KEY="sk-你的密钥" 并重开终端；也可以稍后在 OpenCode 里用 /connect 保存。
3. **编辑 opencode.json**：在 ~/.config/opencode/opencode.json 的 provider 里加一个 ccsub，npm 选 @ai-sdk/anthropic 或 @ai-sdk/openai-compatible，options.baseURL 填 https://www.ccsub.net/api/v1。
4. **声明型号并设为默认**：在 models 里列出要用的型号 ID，例如 claude-sonnet-5，再把顶层 model 设为 ccsub/claude-sonnet-5。
5. **启动验证**：在项目目录运行 opencode，发一句话，到 CCSub「使用记录」核对请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `404 或返回一段网页` | Anthropic 方式的 baseURL 只填了 https://www.ccsub.net，请求变成了 /messages；或者没写 baseURL，被环境变量 ANTHROPIC_BASE_URL 的值带偏了。 | 在 options 里显式写 baseURL: https://www.ccsub.net/api/v1。 |
| `401 authentication_error` | {env:CCSUB_API_KEY} 引用的变量没有设置，或者 /connect 时输入的 provider ID 和配置里的不一致。 | echo $CCSUB_API_KEY 确认有值；/connect 输入的 ID 要和 provider 下的键名完全一样，可用 opencode auth list 检查。 |
| `404 Unknown model` | model 写成了显示名，或者没加 provider 前缀。 | 写成 ccsub/claude-sonnet-5 这种格式，型号 ID 对照 [ccsub.net/zh/models](https://www.ccsub.net/zh/models?utm_source=github-guide)。 |

## 常见问题

**Anthropic 方式的 baseURL 为什么要带 /v1？**

OpenCode 的 @ai-sdk/anthropic 只会在地址后面拼 /messages，只有官方地址才会自动补 /v1。所以要填 https://www.ccsub.net/api/v1（或 https://www.ccsub.net/v1），不能像 Claude Code 那样只填域名。

**用 @ai-sdk/anthropic 还是 @ai-sdk/openai-compatible？**

两种都能接 CCSub。调用 claude- 开头的型号建议用 @ai-sdk/anthropic；调用 gpt- 开头的型号用 @ai-sdk/openai-compatible，它请求的是 /chat/completions。

**Key 写在配置文件里安全吗？**

更推荐用 {env:CCSUB_API_KEY} 引用环境变量，或者在 OpenCode 里执行 /connect 选 Other、输入 provider ID ccsub 后粘贴 Key，Key 会保存在 ~/.local/share/opencode/auth.json，不会进项目仓库。

**项目里的 opencode.json 和全局配置哪个生效？**

两份会合并，同名字段以项目里的 opencode.json 为准。Key 不要写进会提交到 Git 的项目配置。

**model 应该填什么？**

格式是 provider ID 加型号 ID，例如 ccsub/claude-sonnet-5。型号 ID 要先在 provider 的 models 里声明，全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[OpenCode 接入 CCSub：opencode.json 的 provider 和 baseURL 怎么写](https://www.ccsub.net/zh/integrations/opencode?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
