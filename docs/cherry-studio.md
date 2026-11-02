# Cherry Studio 添加自定义提供商：API 地址怎么填、/v1 自动补全规则

> 开源的桌面 AI 客户端，一个提供商可以同时配置 OpenAI 和 Anthropic 两种地址。要注意它会自动在地址后补 /v1。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| OpenAI 地址 | `https://www.ccsub.net/api/v1` | 已含 /v1，不会再重复补 |
| Anthropic 地址 | `https://www.ccsub.net` | 会自动补成 /v1/messages |
| API 密钥 | `sk-你的CCSub密钥` |  |
| 模型 | `claude-sonnet-5` | 点「同步模型」自动拉取 |

## 配置步骤

1. **创建 CCSub API Key**：注册 CCSub，在控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **添加服务商**：打开 Cherry Studio，进入 设置 → 模型服务，点「添加服务商」，在「添加自定义提供商」里填提供商名称 CCSub 和 API 密钥。
3. **填写端点地址**：在端点设置里，OpenAI 填 https://www.ccsub.net/api/v1，Anthropic 填 https://www.ccsub.net；对照下方「请求路径」预览确认地址正确。
4. **同步模型并检测**：保存后在提供商页面点「同步模型」拉取型号列表，再点「检测」测试连通。
5. **开始对话**：新建对话，选择 CCSub 下的型号，例如 claude-sonnet-5，发一句话后到 CCSub「使用记录」核对。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `检测失败，提示 404` | 地址里的 /v1 重复了（例如填了 https://www.ccsub.net/v1/v1），或者把 /chat/completions 也写进了地址。 | OpenAI 地址只填到 https://www.ccsub.net/api/v1，看「请求路径」预览是不是 /api/v1/chat/completions。 |
| `同步模型拿不到列表 / 返回网页` | 地址拼出来的 [ccsub.net/zh/models](https://www.ccsub.net/zh/models?utm_source=github-guide) 路径不对，请求落到了网站页面上。 | OpenAI 地址用 https://www.ccsub.net/api/v1，型号列表会从 /api/v1/models 拉取。 |
| `401 authentication_error: Invalid or disabled API key` | API 密钥粘贴时带了空格，或者 Key 在 CCSub 控制台已禁用。 | 重新粘贴 Key，在控制台确认它是启用状态。 |
| `402 insufficient_balance` | 账户余额不足，或月卡当日额度已用完。 | 到 [ccsub.net/zh/purchase](https://www.ccsub.net/zh/purchase?utm_source=github-guide) 充值；月卡额度北京时间 0 点重置。 |

## 常见问题

**地址末尾加 / 还能跳过 v1 吗？**

不能了。这是旧版本（1.6 及以前）的规则，现在的版本会先去掉末尾的 /，再自动补 /v1。只有地址路径里已经有 /v1 这类版本号，或者以 # 结尾时，才不会自动补。网上的旧教程还在写「/ 结尾忽略 v1」，按新规则来即可。

**OpenAI 地址填 https://www.ccsub.net 行不行？**

可以，会被补成 https://www.ccsub.net/v1/chat/completions，同样能用。CCSub 文档统一写 https://www.ccsub.net/api/v1，路径里已有 /v1，Cherry Studio 不会重复添加。

**# 结尾是什么意思？**

在地址末尾加 # 表示「按我填的原样用，不要自动补版本号」。如果写成完整的接口地址加 #（例如 .../chat/completions#），就会直接请求这个完整地址。接 CCSub 一般用不到。

**旧版 Cherry Studio（1.x）怎么配？**

1.x 版本在「提供商类型」下拉里选 OpenAI 或 Anthropic，地址填法和本文相同；获取型号用「管理」→「获取模型列表」，检测按钮同样叫「检测」。

**model 应该填什么？**

点「同步模型」会从 CCSub 拉取全部型号 ID，也可以手动添加 claude-sonnet-5 等 ID，完整列表见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Cherry Studio 接入 CCSub：添加自定义提供商和 API 地址填写](https://www.ccsub.net/zh/integrations/cherry-studio?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
