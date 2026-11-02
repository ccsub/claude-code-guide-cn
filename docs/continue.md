# Continue 接入中转站：config.yaml 里的 apiBase 和 apiKey 怎么写

> 支持 VS Code 和 JetBrains 的开源 AI 编程插件，用 config.yaml 配置模型。provider 选 anthropic 或 openai，apiBase 都填 /api/v1。

示例里的地址和 Key 以 CCSub 为例；用其他兼容同一协议的中转站，换成对应的地址和 Key 即可。

## 速填表

| 设置项 | 填写 | 注意 |
|---|---|---|
| apiBase | `https://www.ccsub.net/api/v1` | provider 为 anthropic 时也要带 /v1 |
| apiKey | `sk-你的CCSub密钥` | 推荐用 secrets 引用 |
| model | `claude-sonnet-5` |  |

**~/.continue/config.yaml**

```yaml
name: CCSub
version: 1.0.0
schema: v1
models:
  - name: CCSub Claude
    provider: anthropic
    model: claude-sonnet-5
    apiBase: https://www.ccsub.net/api/v1
    apiKey: ${{ secrets.CCSUB_API_KEY }}
    roles: [chat, edit, apply]
```

## 配置步骤

1. **安装 Continue 并创建 CCSub Key**：在 VS Code 或 JetBrains 插件市场安装 Continue，在 CCSub 控制台「API 密钥」页面创建 sk- 开头的 Key。
2. **保存 Key 到 .env**：在 ~/.continue/.env 里写一行 CCSUB_API_KEY=sk-你的密钥。
3. **打开 config.yaml**：打开 Continue 侧边栏（VS Code 按 Cmd/Ctrl+L），点聊天输入框上方的配置下拉，点 Local Config 旁边的齿轮。
4. **添加模型**：在 models 下添加一项：provider 写 anthropic 或 openai，model 写型号 ID，apiBase 写 https://www.ccsub.net/api/v1，apiKey 写 ${{ secrets.CCSUB_API_KEY }}。
5. **选择模型并验证**：保存后在聊天框的模型下拉里选中它，发一句话，到 CCSub「使用记录」核对请求。

## 常见报错

| 报错 | 原因 | 解决 |
|---|---|---|
| `404 Not Found（provider: anthropic）` | apiBase 只填了域名，请求变成了 https://www.ccsub.net/messages。 | apiBase 改成 https://www.ccsub.net/api/v1。 |
| `401 authentication_error` | ${{ secrets.CCSUB_API_KEY }} 没读到值：.env 文件位置不对，或变量名拼写不一致。 | 确认 ~/.continue/.env 里有 CCSUB_API_KEY=sk-...，名字和 config.yaml 里引用的完全一致。 |
| `Agent 模式下模型不调用工具` | Continue 没识别出这个型号支持工具调用。 | 在这个模型下加 capabilities: [tool_use]。 |
| `配置文件报 schema 错误` | 缺少顶层必填字段 name、version、schema。 | 文件开头补上 name、version: 1.0.0、schema: v1 三行。 |

## 常见问题

**config.json 还能用吗？**

Continue 官方文档说明 config.yaml 已取代 config.json，后者已弃用。新配置请写在 ~/.continue/config.yaml。

**provider: anthropic 的 apiBase 为什么要带 /v1？**

Continue 会在 apiBase 后面直接拼 messages，默认值本身就是 https://api.anthropic.com/v1/。只填 https://www.ccsub.net 会请求到 /messages，结果是 404，所以要填 https://www.ccsub.net/api/v1。

**Key 直接写在 config.yaml 里可以吗？**

可以，但更推荐 ${{ secrets.CCSUB_API_KEY }}：Continue 会依次从项目根目录或 .continue/.env、再从 ~/.continue/.env 读取，Key 不会出现在配置文件里。

**能用 CCSub 做 Tab 自动补全吗？**

技术上可以给模型加 autocomplete 角色，但 Continue 官方文档指出聊天模型做自动补全效果往往不好，不建议把对话型号用作 autocomplete。

**model 应该填什么？**

model 可填 claude-sonnet-5、gpt-5.5 等，全部可用型号 ID 见 CCSub 型号列表页。

---

完整教程（更多写法和说明）：[Continue 接入 CCSub：config.yaml 里 apiBase 和 apiKey 怎么写](https://www.ccsub.net/zh/integrations/continue?utm_source=github-guide)

返回：[目录](../README.md) · [常见报错速查](errors.md)
