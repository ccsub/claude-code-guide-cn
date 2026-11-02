# Claude Code / Codex 中转站接入指南 · Claude API 中转 国内使用

在国内用 Claude Code、Codex CLI、Cursor、Cline 这类 AI 编程工具，最省事的办法是接一个 **Claude 中转站**，也就是 Claude API 中转服务；用 Codex 的就接 Codex 中转。工具本身不用改，只要做两件事：把请求地址换成中转站的地址，再填上中转站发的 Key。

这个仓库把常用工具的配置写法、地址填法和常见报错整理在一起，复制就能用。

- 示例里的地址和 Key 以 [CCSub](https://www.ccsub.net/zh?utm_source=github-guide) 为例。本仓库由 CCSub 维护。
- 用其他兼容 Anthropic / OpenAI 协议的中转站，把地址和 Key 换成对应的值即可，规则是一样的。
- 所有写法都只用工具官方支持的设置项（环境变量、配置文件），不需要破解或修改客户端。

[English](README.en.md)

## 目录

- [30 秒看懂：地址到底怎么填](#30-秒看懂地址到底怎么填)
- [Claude Code 三分钟接入](#claude-code-三分钟接入)
- [各工具详细配置](#各工具详细配置)
- [常见报错速查](#常见报错速查)
- [一键自检脚本](#一键自检脚本)
- [省钱和少出错的习惯](#省钱和少出错的习惯)
- [怎么挑中转站](#怎么挑中转站)
- [常见问题](#常见问题)

## 30 秒看懂：地址到底怎么填

AI 编程工具发请求只有两种协议：**Anthropic Messages**（`/v1/messages`）和 **OpenAI 兼容**（`/chat/completions`、`/responses`）。中转站一般两种都提供，区别只在地址后面要不要带路径。

判断规则只有一条：**工具会不会自己在地址后面补 `/v1`**。

- 会自己补的（Claude Code、Zed 的 anthropic_compatible、Cline 和 Cherry Studio 的 Anthropic 选项）：只填域名，**不要**加 `/v1`。
- 不会补的（Codex CLI、Cursor、Continue、OpenCode、Kilo Code 等）：地址里**必须**带上版本路径。在 CCSub 是 `/api/v1`。

「连不上」「404」「返回了一整页 HTML」，九成是这一步填错了。

| 工具 | 协议 | 地址填（以 CCSub 为例） | Key 填在哪 | 最容易踩的坑 | 详细配置 |
|---|---|---|---|---|---|
| Claude Code | Anthropic | `https://www.ccsub.net` | `ANTHROPIC_AUTH_TOKEN` | 不要带 `/v1`，末尾不加斜杠 | [查看](docs/claude-code.md) |
| Codex CLI | OpenAI Responses | `https://www.ccsub.net/api/v1` | `env_key` 指定的变量 | 新版不读 `OPENAI_BASE_URL`，要写 `~/.codex/config.toml` | [查看](docs/codex-cli.md) |
| Cursor | OpenAI | `https://www.ccsub.net/api/v1` | Settings → Models → OpenAI API Key | 要打开 Use OpenAI API Key 开关；型号名不能以 `claude-` 开头 | [查看](docs/cursor.md) |
| CC Switch | 两种 | 预设列表里选「CCSub」 | 预设里填 | 手动添加时地址填 `https://www.ccsub.net`，不勾「完整 URL」 | [查看](docs/cc-switch.md) |
| Cline | 两种 | Anthropic：`https://www.ccsub.net`；OpenAI Compatible：`https://www.ccsub.net/api/v1` | API Key | Anthropic 要先勾 Use custom base URL | [查看](docs/cline.md) |
| OpenCode | 两种 | `https://www.ccsub.net/api/v1` | `apiKey` 或 `/connect` | 两种协议都要带 `/v1`；model 写成 `provider/型号` | [查看](docs/opencode.md) |
| Continue | 两种 | `https://www.ccsub.net/api/v1` | `apiKey`（推荐用 secrets） | provider 是 anthropic 时也要带 `/v1` | [查看](docs/continue.md) |
| Kilo Code | 两种 | `https://www.ccsub.net/api/v1` | API key | 在 Providers 页添加 Custom provider | [查看](docs/kilo-code.md) |
| Zed | 两种 | anthropic_compatible：`https://www.ccsub.net`；openai_compatible：`https://www.ccsub.net/api/v1` | 界面里填或环境变量 | anthropic_compatible 不带 `/v1` | [查看](docs/zed.md) |
| Cherry Studio | 两种 | OpenAI：`https://www.ccsub.net/api/v1`；Anthropic：`https://www.ccsub.net` | API 密钥 | 它会自动补 `/v1`，别重复写 | [查看](docs/cherry-studio.md) |

## Claude Code 三分钟接入

Claude Code 只认 Anthropic 协议，接中转站只需要两个环境变量：

| 变量 | 值 | 说明 |
|---|---|---|
| `ANTHROPIC_BASE_URL` | `https://www.ccsub.net` | 请求地址。不要带 `/v1`，不要以斜杠结尾 |
| `ANTHROPIC_AUTH_TOKEN` | `sk-你的密钥` | 以 `Authorization: Bearer` 发送，设置后立即生效，不会弹登录 |
| `ANTHROPIC_MODEL`（可选） | 例如 `claude-sonnet-5` | 固定默认型号；不设也可以在会话里用 `/model` 切换 |

**macOS / Linux**（zsh 写 `~/.zshrc`，bash 写 `~/.bashrc`）：

```bash
echo 'export ANTHROPIC_BASE_URL="https://www.ccsub.net"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-你的密钥"' >> ~/.zshrc
source ~/.zshrc
claude
```

**Windows（PowerShell）**，写进用户环境变量，然后关掉所有终端窗口重新打开：

```powershell
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'https://www.ccsub.net', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'sk-你的密钥', 'User')
```

**不想改系统变量**，就写进 `~/.claude/settings.json`。它对所有项目生效，而且优先级比 shell 里的变量高：

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://www.ccsub.net",
    "ANTHROPIC_AUTH_TOKEN": "sk-你的密钥"
  }
}
```

**确认真的走了中转站**：

- 在 Claude Code 里执行 `/status`，看到 `Anthropic base URL` 一行显示你填的地址，就说明生效了。
- 也可以先用 curl 单独测地址和 Key。返回 `{"id":"msg_` 开头的 JSON 就是通了，返回 401 说明 Key 不对：

```bash
curl -sS -X POST "$ANTHROPIC_BASE_URL/v1/messages" \
  -H "Authorization: Bearer $ANTHROPIC_AUTH_TOKEN" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-5","max_tokens":16,"messages":[{"role":"user","content":"hi"}]}'
```

> 之前用 claude.ai 账号登录过 Claude Code 的，启动时可能看到 `auth may not work as expected` 的警告。在 Claude Code 里执行 `/logout` 清掉旧登录即可。

VS Code 插件、项目级配置、多个凭证冲突等更多写法，见 [docs/claude-code.md](docs/claude-code.md)。

## 各工具详细配置

| 工具 | 类型 | 文档 |
|---|---|---|
| Claude Code | 终端编程助手（Anthropic 协议） | [docs/claude-code.md](docs/claude-code.md) |
| Codex CLI | 终端编程助手（OpenAI Responses） | [docs/codex-cli.md](docs/codex-cli.md) |
| Cursor | AI 代码编辑器 | [docs/cursor.md](docs/cursor.md) |
| CC Switch | 图形化切换工具，管理 Claude Code / Codex 等的供应商 | [docs/cc-switch.md](docs/cc-switch.md) |
| Cline | VS Code 编程 Agent 插件 | [docs/cline.md](docs/cline.md) |
| OpenCode | 开源终端编程助手 | [docs/opencode.md](docs/opencode.md) |
| Continue | VS Code / JetBrains 插件 | [docs/continue.md](docs/continue.md) |
| Kilo Code | VS Code 编程 Agent 插件 | [docs/kilo-code.md](docs/kilo-code.md) |
| Zed | 开源代码编辑器 | [docs/zed.md](docs/zed.md) |
| Cherry Studio | 桌面 AI 客户端 | [docs/cherry-studio.md](docs/cherry-studio.md) |

可直接复制的配置文件在 [examples/](examples/)。

## 常见报错速查

| 报错 | 多半是 | 怎么办 |
|---|---|---|
| `401 authentication_error` / `Invalid API key · Please run /login` | Key 没带上、带错了，或者被 `ANTHROPIC_API_KEY` 里的旧 Key 覆盖了 | [排查步骤](docs/errors.md#claude-code-401-invalid-api-key) |
| Codex `unexpected status 401 Unauthorized` | 请求还在发往官方地址，或 `env_key` 指向的变量没设置 | [排查步骤](docs/errors.md#codex-401-unauthorized) |
| `There's an issue with the selected model` / 404 | 型号 ID 写错；所有型号都 404 就是地址写错了 | [排查步骤](docs/errors.md#404-model-not-found) |
| `API Error: Connection error` | 请求没出本机，常见于代理变量指向了没开的代理 | [排查步骤](docs/errors.md#claude-code-connection-error) |
| `stream disconnected before completion` | 流式响应中途断开 | [排查步骤](docs/errors.md#codex-stream-disconnected) |
| `402 insufficient_balance` | 余额不够，或当天额度用完 | [排查步骤](docs/errors.md#402-insufficient-balance) |
| `429 rate limit exceeded` / `concurrency limit exceeded` | 请求太密，或同时跑的会话太多 | [排查步骤](docs/errors.md#429-rate-limit-exceeded) |
| `400 Invalid JSON ... Unterminated string` | 请求体太大，传输中被截断 | [排查步骤](docs/errors.md#400-invalid-json-request-too-large) |
| `503 overloaded_error` / `504 timeout_error` | 上游线路暂时不可用或超时 | [503](docs/errors.md#503-upstream-overloaded) · [504](docs/errors.md#504-upstream-timeout) |

完整的 10 类报错和排查步骤见 [docs/errors.md](docs/errors.md)。

## 一键自检脚本

[scripts/check-relay.sh](scripts/check-relay.sh) 会依次检查：本机代理变量、模型列表、Anthropic 协议、OpenAI 协议，并按返回的状态码提示下一步。只依赖 `curl`。

```bash
# 默认测 CCSub
RELAY_API_KEY="sk-你的密钥" bash scripts/check-relay.sh

# 测其他中转站：把两种协议的地址都换掉
RELAY_BASE_URL="https://你的中转站" \
RELAY_OPENAI_BASE_URL="https://你的中转站/v1" \
RELAY_API_KEY="sk-..." bash scripts/check-relay.sh
```

脚本会发两条极短的请求（`max_tokens` 只有 16），会产生几个 Token 的费用。Key 只会发给你指定的地址，不会发到其他地方。

## 省钱和少出错的习惯

- **话题切换就 `/clear`，长对话用 `/compact`**。Claude Code 每一轮都会带上之前的全部上下文，长会话的输入 Token 越积越多，费用也跟着涨。
- **别反复贴大截图、别一次读整个大文件**。请求体过大容易触发 400 截断或 504 超时。
- **同时开的会话和子代理别太多**。很多中转站的并发按账号算，多建几把 Key 也没用。
- **终端开了代理的，给中转站地址加 `NO_PROXY`**。例如 `export NO_PROXY=ccsub.net,.ccsub.net`，避免请求绕到海外再回来，或者被没开的代理卡住。
- **Key 别写进会提交到 Git 的文件**。项目级配置用 `.claude/settings.local.json`，不要用 `.claude/settings.json`。

## 怎么挑中转站

这是一份不带立场的检查清单，挑哪家都适用：

1. **计费是否透明**：有没有逐条的使用记录，能看到每次请求的 Token 数和扣费。
2. **缓存读写怎么计费**：有的按输入价算，有的按更低的缓存价算。Claude Code 的长会话里缓存读占大头，问清楚这一条差别很大。
3. **Key 能不能自己管**：能否随时禁用、删除，能否单独限速。泄露时这很关键。
4. **两种协议是否都有**：只有 OpenAI 兼容接口的，接 Claude Code 会很别扭。
5. **出了问题有没有人回**：报错时能不能拿着请求时间和报错原文找到人。
6. **先小额试用**：先充少量，用自检脚本和日常任务跑几天再决定。

## 常见问题

**Claude Code 的 API Key 填在哪？**

填进环境变量 `ANTHROPIC_AUTH_TOKEN`，或者 `~/.claude/settings.json` 的 `env` 里。地址填进 `ANTHROPIC_BASE_URL`。两个都要设，只设 Key 的话请求还是会发往官方地址。写法见上面的 [Claude Code 三分钟接入](#claude-code-三分钟接入)。

**ANTHROPIC_AUTH_TOKEN 和 ANTHROPIC_API_KEY 用哪个？**

接中转站用 `ANTHROPIC_AUTH_TOKEN`：它以 `Authorization: Bearer` 发送，设置后立即生效。`ANTHROPIC_API_KEY` 在交互模式下首次要你确认一次，之前选过 No 会被静默忽略。两个都设时以中转站的读取规则为准，最好只留一个。

**Codex 怎么接中转？**

新版 Codex CLI 不再读 `OPENAI_BASE_URL`，要在 `~/.codex/config.toml` 里写一个自定义 provider：`base_url` 填中转站的 OpenAI 兼容地址，`wire_api = "responses"`，`env_key` 指向存 Key 的环境变量。完整写法见 [docs/codex-cli.md](docs/codex-cli.md)。

**CC Switch 怎么添加中转站？**

在预设列表里找到中转站直接选，填 Key 即可；列表里没有的，手动添加供应商，地址和 Key 的填法与 Claude Code 相同。见 [docs/cc-switch.md](docs/cc-switch.md)。

**用中转站会不会被封号？**

中转站用的是它自己的上游账号和 Key，你本机不需要登录 Claude 或 ChatGPT 账号，也就不存在你个人账号被封的问题。需要关心的是中转站本身是否稳定、计费是否透明，见 [怎么挑中转站](#怎么挑中转站)。

## 关于 CCSub

本仓库由 [CCSub](https://www.ccsub.net/zh?utm_source=github-guide) 维护。

CCSub 是一个 Claude Code 中转站：一个 Key 同时兼容 Anthropic 和 OpenAI 两种接口，国内不需要梯子；支持支付宝 / USDT 充值，按量计费 1 元 = 1 美元额度。

- [型号列表](https://www.ccsub.net/zh/models?utm_source=github-guide)
- [价格](https://www.ccsub.net/zh/pricing?utm_source=github-guide)
- [使用文档](https://www.ccsub.net/docs?utm_source=github-guide)
- [更新日志](https://www.ccsub.net/zh/changelog?utm_source=github-guide)

## 参与

配置写法跟着各工具的版本在变。发现过时或写错的地方，欢迎提 Issue 或 PR，附上工具版本号和报错原文会更快。

## License

[MIT](LICENSE)
