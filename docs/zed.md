# Zed 接入中转站：anthropic_compatible / openai_compatible 怎么配置

> 高性能开源代码编辑器，内置 Agent 面板。在 settings.json 里添加 Anthropic 兼容或 OpenAI 兼容的提供方即可接入。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| api_url（Anthropic 兼容） | `https://www.ccsub.net` | 不带 /v1，Zed 会拼 /v1/messages |
| api_url（OpenAI 兼容） | `https://www.ccsub.net/api/v1` |  |
| API Key | `sk-你的CCSub密钥` | 在界面填，或设环境变量 CCSUB_API_KEY |
| name | `claude-sonnet-5` |  |

**Zed settings.json（language_models 部分）**

```json
"language_models": {
  "anthropic_compatible": {
    "ccsub": {
      "api_url": "https://www.ccsub.net",
      "available_models": [
        {
          "name": "claude-sonnet-5",
          "display_name": "claude-sonnet-5 (CCSub)",
          "max_tokens": 200000
        }
      ]
    }
  }
}
```

## 配置步骤

1. **创建 CCSub API Key**：注册 CCSub，在控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **打开 Zed 的设置文件**：在 Zed 命令面板执行 zed: open settings file（macOS 快捷键 Cmd+Alt+,）打开 settings.json。
3. **添加 anthropic_compatible 提供方**：在 language_models 下添加 anthropic_compatible，提供方名写 ccsub，api_url 填 https://www.ccsub.net，并在 available_models 里列出型号，例如 claude-sonnet-5。
4. **设置 API Key**：在 Agent 设置（命令 agent: open settings）的 LLM Providers 里给 ccsub 填 Key，或者设置环境变量 CCSUB_API_KEY 后重启 Zed。
5. **在 Agent 面板选型号验证**：打开 Agent 面板，在型号下拉里选 ccsub 下的型号发一句话，再到 CCSub「使用记录」核对。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `Agent 面板的型号列表里没有 ccsub` | settings.json 有语法错误（多了或少了逗号），或者 available_models 是空的。 | Zed 打开 settings.json 时会标出 JSON 错误，修正后保存；至少在 available_models 里写一个型号。 |
| `401 authentication_error: Missing or invalid API key` | 没给 ccsub 设置 Key，或者环境变量名不对（提供方名称里有大写或空格，生成的变量名会不同）。 | 提供方名称用全小写的 ccsub，对应 CCSUB_API_KEY；或者直接在 Agent 设置界面里填 Key。 |
| `404 Not Found` | Anthropic 兼容的 api_url 带了 /v1，请求变成 /v1/v1/messages；或者 api_url 末尾多了斜杠。 | Anthropic 兼容填 https://www.ccsub.net，OpenAI 兼容填 https://www.ccsub.net/api/v1，末尾都不加斜杠。 |

## 常见问题

**Anthropic 兼容的 api_url 要带 /v1 吗？**

不要。Zed 会在 api_url 后面拼 /v1/messages，填 https://www.ccsub.net 即可。OpenAI 兼容则相反，要填到 /api/v1，Zed 只在后面拼 /chat/completions。

**Key 能写进 settings.json 吗？**

Zed 官方文档明确要求不要把 Key 写进 settings.json。在 Agent 设置界面里填，或者用环境变量：变量名是提供方名称转成大写下划线再加 _API_KEY，提供方叫 ccsub 就是 CCSUB_API_KEY。

**为什么发图片没反应？**

兼容提供方的型号默认不开启图片输入。在 available_models 里给这个型号加 capabilities，把 images 设为 true。

**max_tokens 填什么？**

在 Zed 里 max_tokens 表示上下文窗口长度，用来决定能带多少历史内容，示例里写的是 200000，按你的需要调整即可；单次输出上限是另一个字段 max_output_tokens。

**model 应该填什么？**

available_models 里的 name 就是请求时的 model，可填 claude-sonnet-5 等，全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Zed 接入 CCSub：anthropic_compatible / openai_compatible 怎么配置](https://www.ccsub.net/zh/integrations/zed?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
