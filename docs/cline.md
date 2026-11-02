# Cline 接入中转站：Anthropic 和 OpenAI Compatible 两种 Base URL 填法

> VS Code 里的开源编程 Agent 插件。Anthropic 和 OpenAI Compatible 两种 Provider 都能填自定义地址，Plan / Act 还能分别用不同型号。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| Anthropic：Base URL | `https://www.ccsub.net` | 勾选 Use custom base URL 后填写 |
| OpenAI Compatible：Base URL | `https://www.ccsub.net/api/v1` |  |
| API Key | `sk-你的CCSub密钥` |  |
| Model / Model ID | `claude-sonnet-5` |  |

## 配置步骤

1. **安装 Cline 并创建 CCSub Key**：在 VS Code 扩展市场安装 Cline，在 CCSub 控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **打开 API Configuration**：点开 Cline 侧边栏，点右上角齿轮进入设置，切到 API Configuration。
3. **选 API Provider 并填地址**：选 Anthropic 时勾选 Use custom base URL，填 https://www.ccsub.net；选 OpenAI Compatible 时 Base URL 填 https://www.ccsub.net/api/v1。
4. **填 Key 和型号**：把 CCSub 的 Key 填进 API Key 栏。Anthropic 在 Model 下拉里选型号；OpenAI Compatible 在 Model ID 里选或输入型号 ID，例如 claude-sonnet-5。
5. **验证**：在 Cline 里发一个任务，到 CCSub「使用记录」核对请求和实际扣费。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `400 错误，只在 Anthropic + 自定义地址时出现` | Cline 4.1.22 版本的一个问题导致自定义 Anthropic 地址返回 400，4.1.23 已修复。 | 把 Cline 升级到 4.1.23 或更新版本。 |
| `Model ID 下拉是空的` | Base URL 填错，Cline 请求 {Base URL}/models 没拿到列表。 | Base URL 改成 https://www.ccsub.net/api/v1；也可以选 Use custom model ID 手动输入型号 ID。 |
| `401 authentication_error: Missing or invalid API key` | Key 填到了别的 Provider 的输入框，或复制时带了空格。 | 确认当前选中的 API Provider 和填 Key 的输入框一致，重新粘贴。 |
| `404 Unknown model` | 手动输入的型号 ID 有拼写错误。 | 对照 [ccsub.net/zh/models](https://www.ccsub.net/zh/models?utm_source=github-guide) 里的 ID 重新填写，型号 ID 用连字符。 |

## 常见问题

**选 Anthropic 还是 OpenAI Compatible？**

都可以。Anthropic 方式的型号只能从 Cline 内置的下拉列表里选；OpenAI Compatible 的 Model ID 可以从 CCSub 拉取的列表里选，也可以手动输入，型号更灵活。

**Anthropic 方式的地址要不要带 /v1？**

不用。填 https://www.ccsub.net 即可，只写域名时 Cline 会自己补上 /v1。填 https://www.ccsub.net/v1 也能用，但不要写成 /api/v1/v1 这种多一层的路径。

**Cline 里显示的费用一直是 0？**

OpenAI Compatible 的 MODEL CONFIGURATION 里价格默认是 0，Cline 就按 0 显示。实际扣费以 CCSub 控制台「使用记录」为准，也可以把单价手动填进 Input / Output Price。

**Plan 和 Act 能用不同型号吗？**

可以。勾选 Use different models for Plan and Act modes，会出现 Plan Mode 和 Act Mode 两个标签，分别选型号即可，两边可以都用 CCSub。

**model 应该填什么？**

model 可填 claude-sonnet-5 等，全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Cline 接入 CCSub：Anthropic 和 OpenAI Compatible 两种 base_url 填法](https://www.ccsub.net/zh/integrations/cline?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
