# Cursor 接入中转站：Override OpenAI Base URL 和自定义模型怎么设置

> AI 代码编辑器，只能通过「Override OpenAI Base URL」接入第三方接口。Tab 补全不走自定义 Key，型号名不能以 claude- 开头。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| OpenAI API Key | `sk-你的CCSub密钥` | 填完要打开 Use OpenAI API Key 开关 |
| Override OpenAI Base URL | `https://www.ccsub.net/api/v1` | 末尾不要加斜杠 |
| 自定义模型名 | `gpt-5.5` | 不要用 claude- 开头的名字 |

## 配置步骤

1. **创建 CCSub API Key**：注册 CCSub，在控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **打开 Cursor 的 API Keys 设置**：打开 Cursor Settings → Models，滚到底部展开 API Keys。
3. **填 OpenAI API Key 并打开开关**：在 OpenAI API Key 里粘贴 CCSub 的 Key，并打开 Use OpenAI API Key 开关；只粘贴不开开关，请求不会带上 Key。
4. **打开 Override OpenAI Base URL**：打开 Override OpenAI Base URL，填入 https://www.ccsub.net/api/v1。
5. **添加自定义模型并在对话里选用**：在 Models 页添加要用的型号名（例如 gpt-5.5），在 Chat / Agent 的模型下拉里选中它发一句话，再到 CCSub「使用记录」核对。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `Model name is not valid` | OpenAI API Key 填了，但 Use OpenAI API Key 开关没打开，请求没带 Key。Cursor 某次更新加了这个开关，老用户升级后默认是关闭的。 | 回到 Settings → Models → API Keys，打开 Use OpenAI API Key 开关。 |
| `This model does not support custom API keys` | 覆盖地址打开时选了 Cursor 自家的模型。 | 改选你添加的自定义型号；要用 Cursor 自带模型就先关闭 Override OpenAI Base URL。 |
| `自定义型号提示已存在 / already available` | 填的名字和 Cursor 内置的型号名冲突。 | 直接在模型列表里启用同名的内置型号即可，覆盖地址打开时它也会走 CCSub；或者换一个 CCSub 支持的型号 ID。 |
| `401 authentication_error: Invalid or disabled API key` | Key 粘贴错误，或在 CCSub 控制台被禁用。 | 重新复制 Key，确认它在控制台是启用状态。 |

## 常见问题

**Cursor 里能用 claude- 开头的型号走 CCSub 吗？**

不行。Cursor 按型号名判断用哪一栏的 Key：以 claude- 开头的会走 Anthropic API Key 那一栏，而那一栏不能改地址，请求不会发到 CCSub。在 Cursor 里通过 CCSub 调用时，model 填 gpt-5.5 这类 OpenAI 系型号 ID。

**Tab 补全会走 CCSub 吗？**

不会。Cursor 官方说明自定义 API Key 只用于聊天类模型，Tab 补全始终使用 Cursor 自带的模型。

**Override OpenAI Base URL 要带 /v1 吗？**

要。填 https://www.ccsub.net/api/v1，Cursor 会在后面拼 /chat/completions。末尾不要加斜杠。

**打开覆盖地址后，Cursor 自带的模型报错了？**

覆盖地址对除 Claude、Gemini 以外的所有型号生效，包括 Cursor 自家的模型，这些模型会提示不支持自定义 Key。想用 Cursor 自带模型时，先把 Override OpenAI Base URL 关掉。

**需要在本机开代理吗？**

不需要。使用自定义地址时，请求是从 Cursor 的服务器发出的，不是从你的电脑发出，所以本机代理不影响，地址也必须是公网可访问的，CCSub 的地址满足这个条件。

---

完整教程（更多写法和说明）：[Cursor 接入 CCSub：Override OpenAI Base URL 和自定义模型怎么设置](https://www.ccsub.net/zh/integrations/cursor?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
