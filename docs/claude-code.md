# Claude Code 接入中转站：ANTHROPIC_BASE_URL 和 ANTHROPIC_AUTH_TOKEN 怎么配置

> Anthropic 官方的终端编程助手，只支持 Anthropic 协议。设置 ANTHROPIC_BASE_URL 和 ANTHROPIC_AUTH_TOKEN 两个环境变量即可接入。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| ANTHROPIC_BASE_URL | `https://www.ccsub.net` | 不要加 /v1，末尾不要有斜杠 |
| ANTHROPIC_AUTH_TOKEN | `sk-你的CCSub密钥` |  |
| 模型（可选） | `claude-sonnet-5` | 启动后用 /model 切换 |

**macOS / Linux：写入 ~/.zshrc（bash 用户写 ~/.bashrc）**

```bash
echo 'export ANTHROPIC_BASE_URL="https://www.ccsub.net"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-你的密钥"' >> ~/.zshrc
source ~/.zshrc
claude
```

## 配置步骤

1. **安装 Claude Code**：先装 Node.js 18 以上版本，再执行 npm install -g @anthropic-ai/claude-code@latest（macOS / Linux 需要 sudo），用 claude --version 确认安装成功。
2. **创建 CCSub API Key**：注册 CCSub，进入控制台「API 密钥」页面创建密钥，复制 sk- 开头的 Key。
3. **设置两个环境变量**：把 ANTHROPIC_BASE_URL 设为 https://www.ccsub.net，ANTHROPIC_AUTH_TOKEN 设为你的 Key。macOS / Linux 写进 ~/.zshrc 或 ~/.bashrc，Windows 用 PowerShell 的 SetEnvironmentVariable 写入用户变量，也可以写进 ~/.claude/settings.json 的 env。
4. **重开终端并启动**：关闭所有终端窗口后重新打开，进入项目目录执行 claude，首次启动按提示回车即可。
5. **确认走的是 CCSub**：在 Claude Code 里执行 /status，看到 Anthropic base URL 为 https://www.ccsub.net；再发一句话，到 CCSub「使用记录」里核对这次请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `401 authentication_error: Missing or invalid API key` | ANTHROPIC_AUTH_TOKEN 没生效、Key 复制时多了空格，或者 Key 已被禁用。 | 在终端执行 echo $ANTHROPIC_AUTH_TOKEN 确认值正确；在控制台确认这把 Key 是启用状态；修改后重开终端。 |
| `一直显示 Connecting...、Connection refused 或请求超时` | ANTHROPIC_BASE_URL 写错（带了 /v1 或多了斜杠），或者终端被代理软件接管。 | 把地址改回 https://www.ccsub.net；退出代理软件后重开终端再试。 |
| `API returned an empty or malformed response (HTTP 200)` | 请求路径不对，服务器返回的是网页而不是接口数据，常见于地址里多写了 /v1、/api 之类的路径。 | ANTHROPIC_BASE_URL 只填 https://www.ccsub.net，不加任何路径。 |
| `设置了 Token 还是弹出登录界面` | 变量写在项目的 .claude/settings.json 或 settings.local.json 里，首次启动、还没信任这个目录时不会生效；或者是 VS Code 插件读不到 ~/.claude/settings.json。 | 把变量写进 shell 配置或 ~/.claude/settings.json；VS Code 插件改用 claudeCode.environmentVariables。 |
| `402 insufficient_balance：余额不足` | 账户余额不够这次请求的预估费用；月卡用户则是当天的额度已经用完。 | 到 [ccsub.net/zh/purchase](https://www.ccsub.net/zh/purchase?utm_source=github-guide) 充值余额。月卡每日额度在北京时间 0 点重置，额度用完后会改扣账户余额。 |
| `404 Unknown model` | 型号 ID 写错，例如写成了带空格的显示名。 | 型号 ID 用连字符，例如 claude-sonnet-5；对照 [ccsub.net/zh/models](https://www.ccsub.net/zh/models?utm_source=github-guide) 里的 ID 重新填写。 |

## 常见问题

**ANTHROPIC_BASE_URL 要不要带 /v1？**

不要。Claude Code 会自己在地址后面拼 /v1/messages，填 https://www.ccsub.net 即可。写成 https://www.ccsub.net/v1 会变成 /v1/v1/messages，请求会失败。

**用 ANTHROPIC_AUTH_TOKEN 还是 ANTHROPIC_API_KEY？**

按 CCSub 文档统一用 ANTHROPIC_AUTH_TOKEN。它以 Authorization: Bearer 请求头发送，设置后立即生效、不会弹登录界面；ANTHROPIC_API_KEY 需要在交互模式里确认一次，之前拒绝过会被静默忽略。CCSub 两种请求头都认。

**环境变量设好了，Claude Code 还是连的官方？**

旧终端不会读取新写入的变量，关闭所有终端窗口重新打开。进入 Claude Code 后执行 /status，Status 页里出现 Anthropic base URL 一行并显示 https://www.ccsub.net，才说明地址生效了。

**VS Code 里的 Claude Code 插件怎么配置？**

官方文档建议写在 VS Code 的用户设置里：命令面板执行 Preferences: Open User Settings (JSON)，添加 claudeCode.environmentVariables，填入 ANTHROPIC_BASE_URL 和 ANTHROPIC_AUTH_TOKEN。只写在 ~/.claude/settings.json 的话，插件启动前的登录检查读不到，可能仍然要求登录。

**model 应该填什么？**

启动后输入 /model 选择即可；想固定默认型号，可以在 env 里加 ANTHROPIC_MODEL，例如 claude-sonnet-5。全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Claude Code 接入 CCSub：ANTHROPIC_BASE_URL 和 Token 怎么配置](https://www.ccsub.net/zh/integrations/claude-code?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
