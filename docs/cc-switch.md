# CC Switch 添加供应商：一键切换 Claude Code / Codex 的中转站

> 开源的图形化切换工具，帮你改写 Claude Code、Codex、OpenCode 等工具的配置。预设列表里就有 CCSub，选中后填 Key 即可。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| 预设 | `CCSub` | 在预设列表里选中，填 Key 即可 |
| API Key | `sk-你的CCSub密钥` |  |
| 请求地址（手动配置时） | `https://www.ccsub.net` | 不勾选「完整 URL」 |

## 配置步骤

1. **下载安装 CC Switch**：从 GitHub Releases 下载：Windows 用 .msi，macOS 用 .dmg 或 brew install --cask cc-switch，Linux 有 .deb / .rpm / .AppImage。系统要求 Windows 10、macOS 12、Ubuntu 22.04 及以上。
2. **选择要配置的工具**：打开 CC Switch，在侧边栏选 Claude Code（或 Codex、OpenCode 等），点右上角「+」添加供应商。
3. **选 CCSub 预设并填 Key**：在预设列表里搜索或点选 CCSub，把 CCSub 控制台创建的 sk- 开头的 Key 填进 API Key，点「添加」。
4. **切换到 CCSub**：在供应商卡片上点「启用」（新版本按钮叫「切换」），卡片显示「使用中」即表示已写入该工具的配置。
5. **验证**：Claude Code 新开一个会话，Codex 需要重启；发一句话后到 CCSub「使用记录」核对请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `切换后 Claude Code 仍提示 401` | API Key 粘贴时带了空格，或者之前在 shell 里也设置了 ANTHROPIC_AUTH_TOKEN。settings.json 优先级更高，但旧变量容易让人误判。 | 在 CC Switch 里编辑 CCSub 卡片重新粘贴 Key；用 Claude Code 的 /status 查看实际生效的地址和凭证来源。 |
| `在工具里用 /model 改的型号，切换后又变回去了` | CC Switch 切换供应商时会按卡片里的配置重写型号字段。 | 把常用型号写进 CCSub 卡片的「主模型」或各默认模型字段，而不是只在工具里临时修改。 |
| `老卡片的地址和预设不一致` | 以前用旧版预设保存的卡片不会随 CC Switch 升级自动更新。 | 删除旧卡片，重新从预设列表添加 CCSub。 |

## 常见问题

**CC Switch 里有 CCSub 预设吗？**

有。CCSub 在 Claude Code、Codex、OpenCode 等工具的预设列表里都有，选中后只需要填 API Key，请求地址已经预填好。Gemini CLI 目前没有 CCSub 预设。

**手动配置时请求地址填什么？**

Claude Code 填 https://www.ccsub.net，不要带 /v1，也不要勾选「完整 URL」。「完整 URL」只在开启本地路由时才有作用。

**点了「检测连通」显示成功，为什么还是用不了？**

「检测连通」只检查地址能不能连上，不验证 Key 和型号。Key 填错、余额不足都要在实际发消息时才会报出来，看 CCSub「使用记录」最准。

**切换供应商后 Codex 没变化？**

Claude Code 可以热切换，Codex 需要退出后重新启动才会读取新配置。

**CC Switch 会把我的配置写到哪里？**

Claude Code 写入 ~/.claude/settings.json 的 env；Codex 写入 ~/.codex/config.toml。切换 Codex 时原来的 auth.json 会先备份到 ~/.cc-switch/codex-login-stash.json。

---

完整教程（更多写法和说明）：[CC Switch 接入 CCSub：选预设填 Key，或手动添加供应商](https://www.ccsub.net/zh/integrations/cc-switch?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
