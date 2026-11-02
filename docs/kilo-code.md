# Kilo Code 接入中转站：Custom provider 和 Base URL 怎么填

> VS Code 里的开源编程 Agent，新版基于 OpenCode 重写。在 Providers 页添加 Custom provider，OpenAI Compatible 和 Anthropic Messages 都能接。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| Provider API | `OpenAI Compatible` | 或 Anthropic Messages |
| Base URL | `https://www.ccsub.net/api/v1` | 两种 Provider API 都要带 /v1 |
| API key | `sk-你的CCSub密钥` |  |
| Model ID | `claude-sonnet-5` |  |

## 配置步骤

1. **安装 Kilo Code 并创建 CCSub Key**：在 VS Code 扩展市场安装 Kilo Code，在 CCSub 控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **打开 Custom provider 对话框**：进入 Kilo Code 设置（齿轮图标）→ Providers 标签页，滚到最底部点 Custom provider。
3. **填写提供方信息**：Provider ID 填 ccsub，Display name 填 CCSub，Provider API 选 OpenAI Compatible（或 Anthropic Messages），Base URL 填 https://www.ccsub.net/api/v1，API key 填 CCSub 的 Key。
4. **添加型号**：OpenAI Compatible 可点 Fetch models 自动拉取；Anthropic Messages 需要点 Add model 手动输入型号 ID，例如 claude-sonnet-5。填完点 Submit。
5. **选择型号并验证**：在对话框的型号选择里选 ccsub 下的型号，发一个任务，到 CCSub「使用记录」核对请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `Anthropic Messages 方式报 404` | Base URL 只填了 https://www.ccsub.net，请求变成了 /messages。 | 改成 https://www.ccsub.net/api/v1。 |
| `型号的上下文上限为 0，上下文管理不正常` | 通过对话框添加的型号不能设置 token 上限，不填时默认是 0。 | 在 kilo.json 里给这个型号补上 limit 的 context 和 output。 |
| `{env:CCSUB_API_KEY} 没被替换，401` | 环境变量引用只在全局配置 ~/.config/kilo/kilo.json 里生效，写在项目 kilo.json 里不会被解析。 | 把带 {env:...} 的 provider 配置移到全局配置文件，或直接在对话框里填 Key。 |
| `401 authentication_error: Missing or invalid API key` | API key 留空了（该字段是可选的），或者 Key 复制错误。 | 编辑 ccsub 提供方，重新粘贴 CCSub 的 Key。 |

## 常见问题

**Base URL 为什么要带 /v1？**

新版 Kilo Code 基于 OpenCode 和 AI SDK，Anthropic Messages 只会在地址后拼 /messages，OpenAI Compatible 拼 /chat/completions，都不会自动补 /v1。所以两种都填 https://www.ccsub.net/api/v1。

**内置的 Anthropic 提供方能改地址吗？**

界面上不能，内置 Anthropic 只让你填 Key。要改地址只能在配置文件里写 provider.anthropic.options.baseURL；更简单的做法是像本文一样添加一个 Custom provider。

**为什么 Fetch models 是灰的？**

Provider API 选 Anthropic Messages 时不支持自动拉取型号，需要点 Add model 手动填型号 ID。选 OpenAI Compatible 时可以用 Fetch models。

**从 Roo Code 迁移过来要注意什么？**

Roo Code 团队在 2026 年 4 月宣布停止维护，仓库已归档，Kilo 官方提供了迁移指南。迁移后要在 Kilo Code 里重新添加 CCSub：注意 Roo Code 的 Anthropic 地址不带 /v1，而 Kilo Code 的 Anthropic Messages 必须带 /v1。

**model 应该填什么？**

model 可填 claude-sonnet-5 等，全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Kilo Code 接入 CCSub：Custom provider 怎么添加、Base URL 怎么填](https://www.ccsub.net/zh/integrations/kilo-code?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
