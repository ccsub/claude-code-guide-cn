# Claude Code / Codex 中转站常见报错速查

接中转站后最常见的 10 类报错：先看报错原文对上号，再按步骤排查。示例地址以 CCSub 为例，其他中转站的报错文案可能略有不同，但原因基本一样。

| 状态码 | 报错 | 一句话结论 |
|---|---|---|
| 401 | [Claude Code 报 401 Invalid API Key 怎么解决](#claude-code-401-invalid-api-key) | Key 没带上或带错了。用 /status 看 Claude Code 实际用的是哪个变量，到 [ccsub.net/zh/keys](https://www.ccsub.net/zh/keys?utm_source=github-guide) 重新复制完整 Key，删掉多余的 ANTHROPIC_API_KEY 后重开终端。 |
| 401 | [Codex 报 unexpected status 401 Unauthorized 怎么解决](#codex-401-unauthorized) | 看报错里的 url 判断请求发去了哪；用自定义 provider + env_key 指定 CCSub 的 Key，并在启动 Codex 的同一个环境里设置好这个变量。 |
| 402 | [报 402 insufficient_balance「余额不足」怎么解决](#402-insufficient-balance) | 账户可用余额不够，或月卡当天额度用完。看 message 是哪种：充值按量余额、等北京时间 0 点额度重置，或在余额本来够时等几分钟再试。 |
| 429 | [报 429 rate limit exceeded / concurrency limit exceeded 怎么解决](#429-rate-limit-exceeded) | 每分钟请求数超了就在 Keys 页面调高这把 Key 的速率或分开用多把 Key；并发超了就减少同时跑的会话和子代理——并发按账号计算，多建 Key 没用。 |
| 404 | [Claude Code 报 There's an issue with the selected model（404 模型不存在）怎么解决](#404-model-not-found) | model 标识写错了，按 /api/v1/models 列表里的 id 改（用短横线）；如果所有型号都 404、返回的是一整页 HTML，就是 Base URL 写错了。 |
| 400 | [报 400 Invalid JSON in request body: Unterminated string（请求体过大）怎么解决](#400-invalid-json-request-too-large) | position 是上千万的数字 = 请求体太大、传输途中被截断：/compact 或 /clear、别反复贴大截图、大文件分段读。position 很小 = 发出去的 JSON 本身格式不对。 |
| 503 | [报 503 overloaded_error「上游线路暂时不可用」怎么解决](#503-upstream-overloaded) | CCSub 已自动换线重试过，这次仍没有可用线路。等一两分钟在原会话里发「继续」，或用 /model 换个型号；不扣费，也不是你的余额问题。 |
| 504 | [报 504 timeout_error「Upstream timed out」怎么解决](#504-upstream-timeout) | 等上游的时间超过上限了。自己调用时改成流式（stream: true），上下文太长就 /compact，长输出拆成几次；偶发一次直接重试即可，不计费。 |
| — | [Claude Code 报 API Error: Connection error（Unable to connect to API）怎么解决](#claude-code-connection-error) | 请求没到 CCSub，多半是本地代理变量指向了没开的代理。env \| grep -i proxy 查一下，unset 掉或给 ccsub.net 加 NO_PROXY；首次启动卡在连不上 api.anthropic.com 则改 ~/.claude.json。 |
| — | [Codex 报 stream disconnected before completion 怎么解决](#codex-stream-disconnected) | 流在结束前断了。确认 base_url 是 https://www.ccsub.net/api/v1，去掉干扰终端的代理，过长的单轮任务调低推理强度或拆小，并在 provider 里调大 stream_max_retries。 |

<a id="claude-code-401-invalid-api-key"></a>

## Claude Code 报 401 Invalid API Key 怎么解决

```text
API Error: 401 {"type":"error","error":{"type":"authentication_error","message":"Invalid or disabled API key"}}
```

同类写法：

- `API Error: 401 {"type":"error","error":{"type":"authentication_error","message":"Missing or invalid API key"}}`
- `Invalid API key · Please run /login`
- `Not logged in · Please run /login`

**结论**：Key 没带上或带错了。用 /status 看 Claude Code 实际用的是哪个变量，到 [ccsub.net/zh/keys](https://www.ccsub.net/zh/keys?utm_source=github-guide) 重新复制完整 Key，删掉多余的 ANTHROPIC_API_KEY 后重开终端。

1. **用 /status 确认 Claude Code 拿到的配置**：在 Claude Code 里输入 /status，Status 页的 Anthropic base URL 应该是 https://www.ccsub.net，并且有一行 Auth token 指向 ANTHROPIC_AUTH_TOKEN。没有 base URL 这一行，说明环境变量根本没进到这个会话。
2. **到控制台重新复制 Key 并单独测一次**：打开 CCSub 控制台的 API Keys 页面，确认这把 Key 是启用状态，点复制拿到完整值（sk- 开头，共 67 个字符）。用本仓库的 [scripts/check-relay.sh](../scripts/check-relay.sh)或控制台的 Key 测试页测一下：能返回内容说明 Key 没问题，问题在 Claude Code 的配置上。
3. **清掉冲突的变量，重开终端再启动**：删掉不用的 ANTHROPIC_API_KEY（它会以 X-Api-Key 头发出，CCSub 优先读这个头），检查 ~/.claude/settings.json 的 env 里有没有旧的 Key 或地址，然后关掉所有终端窗口，新开一个再运行 claude。

详细排查：[Claude Code 报 401 Invalid API Key 怎么解决](https://www.ccsub.net/zh/errors/claude-code-401-invalid-api-key?utm_source=github-guide)

<a id="codex-401-unauthorized"></a>

## Codex 报 unexpected status 401 Unauthorized 怎么解决

```text
unexpected status 401 Unauthorized: {"type":"error","error":{"type":"authentication_error","message":"Missing or invalid API key"}}, url: https://www.ccsub.net/api/v1/responses
```

同类写法：

- `unexpected status 401 Unauthorized: {"type":"error","error":{"type":"authentication_error","message":"Invalid or disabled API key"}}, url: https://www.ccsub.net/api/v1/responses`
- `Missing environment variable: `OPENAI_API_KEY`.`

**结论**：看报错里的 url 判断请求发去了哪；用自定义 provider + env_key 指定 CCSub 的 Key，并在启动 Codex 的同一个环境里设置好这个变量。

1. **看报错末尾的 url**：url 是 https://www.ccsub.net/api/v1/responses，说明请求到了 CCSub、是 Key 有问题；url 是别的地址（比如 OpenAI 或 ChatGPT 的域名），说明你的 base_url 配置根本没生效，先修配置。
2. **在 config.toml 里用自定义 provider 指定 Key**：在 ~/.codex/config.toml 顶部写 model_provider = "ccsub"，再加一个 [model_providers.ccsub] 表，填 base_url = "https://www.ccsub.net/api/v1"、env_key = "OPENAI_API_KEY"、wire_api = "responses"。这样 Codex 只会从 OPENAI_API_KEY 这个变量取 Key。
3. **在启动 Codex 的环境里设置变量并核对 Key**：export OPENAI_API_KEY="sk-..." 之后在同一个终端运行 codex；Key 从控制台 API Keys 页面重新复制，确认是启用状态。桌面版从 Dock 启动时读不到 ~/.zshrc 里的变量，可以先从终端启动验证。

详细排查：[Codex 报 unexpected status 401 Unauthorized 怎么解决](https://www.ccsub.net/zh/errors/codex-401-unauthorized?utm_source=github-guide)

<a id="402-insufficient-balance"></a>

## 报 402 insufficient_balance「余额不足」怎么解决

```text
API Error: 402 {"type":"error","error":{"type":"insufficient_balance","message":"余额不足，请前往 https://www.ccsub.net/purchase 充值"}}
```

同类写法：

- `余额不足（可用 $0.12，本次预估 $0.50），请前往 https://www.ccsub.net/purchase 充值`
- `今日月卡额度（$50/天）已用完，将于北京时间 0 点重置；如需继续使用，请前往 https://www.ccsub.net/purchase 充值余额`
- `unexpected status 402 Payment Required: {"type":"error","error":{"type":"insufficient_balance","message":"余额不足，请前往 https://www.ccsub.net/purchase 充值"}}, url: https://www.ccsub.net/api/v1/responses`

**结论**：账户可用余额不够，或月卡当天额度用完。看 message 是哪种：充值按量余额、等北京时间 0 点额度重置，或在余额本来够时等几分钟再试。

1. **看 message 属于哪一种**：只写「余额不足」是可用余额已经为 0；带「可用 $x，本次预估 $y」是还有余额但不够这次请求的预冻结；写「今日月卡额度已用完」是月卡当天的额度用完、而且按量余额也没有了。
2. **到控制台核对余额和今日额度**：控制台首页看账户余额，月卡页看「剩余今日额度」。使用记录里被拦下的请求费用是 $0，不会扣钱。
3. **充值或等待重置**：按量余额不够就去充值页充值；月卡额度用完可以等北京时间 0 点自动重置，或充一点按量余额继续用。余额明明够却报「本次预估」，多半是并发请求占用了预冻结，几分钟后重试即可。

详细排查：[报 402 insufficient_balance「余额不足」怎么解决](https://www.ccsub.net/zh/errors/402-insufficient-balance?utm_source=github-guide)

<a id="429-rate-limit-exceeded"></a>

## 报 429 rate limit exceeded / concurrency limit exceeded 怎么解决

```text
API Error: 429 {"type":"error","error":{"type":"rate_limit_error","message":"API Key request rate exceeded"}}
```

同类写法：

- `{"type":"error","error":{"type":"concurrency_limit_error","message":"User concurrency limit exceeded"}}`
- `{"type":"error","error":{"type":"rate_limit_error","message":"API Key token rate exceeded"}}`
- `exceeded retry limit, last status: 429 Too Many Requests`

**结论**：每分钟请求数超了就在 Keys 页面调高这把 Key 的速率或分开用多把 Key；并发超了就减少同时跑的会话和子代理——并发按账号计算，多建 Key 没用。

1. **看 message 是哪一种限制**：API Key request rate exceeded 是这把 Key 每分钟请求数超了；API Key token rate exceeded 是你给这把 Key 设的 Token 速率超了；User concurrency limit exceeded 是整个账号同时在等待响应的请求太多。
2. **速率类：到 Keys 页面调整这把 Key**：控制台 API Keys 页面编辑这把 Key，在「速率限制」里打开自定义，把每分钟请求数调高；Token 速率留空表示不限。也可以给不同工具、不同项目各建一把 Key，每把 Key 单独计数。
3. **并发类：减少同时进行的请求**：少开几个同时运行的 Claude Code / Codex 会话，减少并行的子代理或批量脚本的并发数。并发上限按账号计算，账号下所有 Key 共用，多建 Key 不能解决；确实需要更高并发可以联系客服说明使用场景。

详细排查：[报 429 rate limit exceeded / concurrency limit exceeded 怎么解决](https://www.ccsub.net/zh/errors/429-rate-limit-exceeded?utm_source=github-guide)

<a id="404-model-not-found"></a>

## Claude Code 报 There's an issue with the selected model（404 模型不存在）怎么解决

```text
There's an issue with the selected model (claude-opus-6). It may not exist or you may not have access to it. Run /model to pick a different model.
```

同类写法：

- `API Error: 404 {"type":"error","error":{"type":"not_found_error","message":"Unknown model \"opus 4.6\". Did you mean \"claude-opus-4-6\"? Model IDs use hyphens, e.g. claude-opus-4-6 (not \"opus 4.6\"). Full list: https://www.ccsub.net/api/v1/models | 未知模型 ..."}}`
- `unexpected status 404 Not Found: <!DOCTYPE html><html lang="zh">...`

**结论**：model 标识写错了，按 /api/v1/models 列表里的 id 改（用短横线）；如果所有型号都 404、返回的是一整页 HTML，就是 Base URL 写错了。

1. **看清报错里括号中的型号名**：Claude Code 会把当前用的型号写在括号里。拿它去对照 https://www.ccsub.net/api/v1/models 返回的 id，或网站上的型号列表页。CCSub 的 404 报错里通常还会附一句「是不是想用 xxx」。
2. **改成正确的 model 标识**：在 Claude Code 里用 /model 重新选择，或修改 ANTHROPIC_MODEL、settings.json 里的 model、ANTHROPIC_DEFAULT_SONNET_MODEL / OPUS / HAIKU_MODEL 这几个变量。model 标识用短横线连接，例如 claude-opus-4-6，不要写成 opus 4.6。
3. **如果所有型号都报，检查 Base URL**：ANTHROPIC_BASE_URL 应为 https://www.ccsub.net，末尾不要加 /v1；OpenAI 兼容工具填 https://www.ccsub.net/api/v1。地址写错时服务器返回的是一整页 HTML 404，客户端会把它误报成型号问题。

详细排查：[Claude Code 报 There's an issue with the selected model（404 模型不存在）怎么解决](https://www.ccsub.net/zh/errors/404-model-not-found?utm_source=github-guide)

<a id="400-invalid-json-request-too-large"></a>

## 报 400 Invalid JSON in request body: Unterminated string（请求体过大）怎么解决

```text
API Error: 400 {"type":"error","error":{"type":"invalid_request_error","message":"Invalid JSON in request body: Unterminated string in JSON at position 10407567 (line 1 column 10407568)"}}
```

同类写法：

- `{"type":"error","error":{"type":"request_too_large","message":"Request body exceeds 50MB limit (got 52.4MB)"}}`
- `Request body is too large. Please reduce your message size, remove large images, or shorten the conversation history. | 请求体过大，请缩短对话历史、减小图片大小或减少附件。`
- `Invalid JSON in request body: Expected property name or '}' in JSON at position 1 (line 1 column 2)`

**结论**：position 是上千万的数字 = 请求体太大、传输途中被截断：/compact 或 /clear、别反复贴大截图、大文件分段读。position 很小 = 发出去的 JSON 本身格式不对。

1. **看 position 后面的数字**：上千万（例如 10407567、8553900）说明请求体太大、在传输过程中被截断，JSON 不完整；只有几十几百，说明发出的 JSON 本身就写错了，多见于手写的 curl 命令或脚本。
2. **在 Claude Code 里压缩对话**：先用 /context 看看是什么占了上下文，再用 /compact 压缩历史，或者用 /clear 开新对话。截图和图片会以 base64 形式留在历史里，每一轮都会重新发送，尽量压缩后再贴、不要反复贴。
3. **从源头把单个请求变小**：超大的日志、压缩过的 JS、数据文件不要整个读进对话，先让 AI 用 grep、head 之类的命令取需要的部分；自己写代码调用时，图片先缩小分辨率再编码，长对话截断早期历史。

详细排查：[报 400 Invalid JSON in request body: Unterminated string（请求体过大）怎么解决](https://www.ccsub.net/zh/errors/400-invalid-json-request-too-large?utm_source=github-guide)

<a id="503-upstream-overloaded"></a>

## 报 503 overloaded_error「上游线路暂时不可用」怎么解决

```text
API Error: 503 {"type":"error","error":{"type":"overloaded_error","message":"上游线路暂时不可用，请稍后重试（不是您账户余额的问题） | Upstream temporarily unavailable, please retry shortly (this is not about your account balance)."}}
```

同类写法：

- `Upstream overloaded after 3 attempt(s): Our servers are currently overloaded. Please try again later.`
- `API Error: Repeated 529 Overloaded errors`
- `{"type":"error","error":{"type":"api_error","message":"Upstream returned invalid response"}}`

**结论**：CCSub 已自动换线重试过，这次仍没有可用线路。等一两分钟在原会话里发「继续」，或用 /model 换个型号；不扣费，也不是你的余额问题。

1. **等一两分钟，在原会话里发「继续」**：这是暂时性错误，原来的消息还在对话里，不用重新粘贴长提示词，直接发一句「继续」或 try again 即可。Claude Code 在显示这个错误之前已经自动重试过多次。
2. **换一个型号试试**：在 Claude Code 里用 /model 选另一个型号，或在配置里换一个 model 标识。不同型号的请求在 CCSub 内部可能走不同的线路，一个型号暂时没有可用线路时，另一个往往正常。
3. **持续超过 10 分钟再联系客服**：发邮件到 support@ccsub.net，写清楚出错的时间（精确到分钟）、使用的工具和 model 标识、报错原文，方便直接在日志里定位。不要在邮件里发 API Key。

详细排查：[报 503 overloaded_error「上游线路暂时不可用」怎么解决](https://www.ccsub.net/zh/errors/503-upstream-overloaded?utm_source=github-guide)

<a id="504-upstream-timeout"></a>

## 报 504 timeout_error「Upstream timed out」怎么解决

```text
API Error: 504 {"type":"error","error":{"type":"timeout_error","message":"Upstream timed out"}}
```

同类写法：

- `unexpected status 504 Gateway Timeout: {"type":"error","error":{"type":"timeout_error","message":"Upstream timed out"}}, url: https://www.ccsub.net/api/v1/responses`
- `API Error: Request timed out`

**结论**：等上游的时间超过上限了。自己调用时改成流式（stream: true），上下文太长就 /compact，长输出拆成几次；偶发一次直接重试即可，不计费。

1. **偶发的先直接重试**：Claude Code 遇到超时会自动重试；其他工具重新发送一次即可。超时的请求没有产生结果，不会扣费。
2. **自己写代码时改用流式请求**：在请求里加上 stream: true（OpenAI SDK 和 Anthropic SDK 都支持）。流式请求只要上游开始返回第一个字，就不再受首包等待时间限制；非流式请求要等完整结果生成完才返回，长输出最容易 504。
3. **缩短上下文、拆小任务**：上下文越长，上游开始返回第一个字之前的处理时间越长。Claude Code 里用 /compact 压缩历史；一次要生成很长内容的任务，拆成几次请求分别生成。

详细排查：[报 504 timeout_error「Upstream timed out」怎么解决](https://www.ccsub.net/zh/errors/504-upstream-timeout?utm_source=github-guide)

<a id="claude-code-connection-error"></a>

## Claude Code 报 API Error: Connection error（Unable to connect to API）怎么解决

```text
Unable to connect to API (ECONNREFUSED)
```

同类写法：

- `API Error (Connection error.) · Retrying in 1 seconds… (attempt 1/10)`
- `Couldn't connect through your proxy (ECONNREFUSED)`
- `TypeError (fetch failed)`
- `Unable to connect to Anthropic services · Failed to connect to api.anthropic.com: ERR_BAD_REQUEST`

**结论**：请求没到 CCSub，多半是本地代理变量指向了没开的代理。env \| grep -i proxy 查一下，unset 掉或给 ccsub.net 加 NO_PROXY；首次启动卡在连不上 api.anthropic.com 则改 ~/.claude.json。

1. **检查终端里的代理变量**：运行 env \| grep -i proxy。如果看到 HTTPS_PROXY、HTTP_PROXY、ALL_PROXY 指向 127.0.0.1:7890 之类的地址，而代理软件并没有开，Claude Code 的请求就会被送到一个不存在的代理上。unset 掉它们，或者设置 NO_PROXY=www.ccsub.net,ccsub.net 让 CCSub 直连。
2. **用 curl 确认能连到 CCSub**：在同一个终端运行 curl -sS -X POST https://www.ccsub.net/v1/messages -o /dev/null -w '%{http_code}\n'。返回 401 说明网络是通的（只是没带 Key）；连不上或超时，就是本机网络、代理或防火墙的问题。
3. **首次启动卡住就跳过官方连通性检查**：第一次运行 claude 时如果提示 Unable to connect to Anthropic services，是新手引导在检查 api.anthropic.com。在 ~/.claude.json 里加上 "hasCompletedOnboarding": true 后重新启动即可。

详细排查：[Claude Code 报 API Error: Connection error（Unable to connect to API）怎么解决](https://www.ccsub.net/zh/errors/claude-code-connection-error?utm_source=github-guide)

<a id="codex-stream-disconnected"></a>

## Codex 报 stream disconnected before completion 怎么解决

```text
stream disconnected before completion: stream closed before response.completed
```

同类写法：

- `stream disconnected before completion: error sending request for url (https://www.ccsub.net/api/v1/responses)`
- `Reconnecting... 2/5`

**结论**：流在结束前断了。确认 base_url 是 https://www.ccsub.net/api/v1，去掉干扰终端的代理，过长的单轮任务调低推理强度或拆小，并在 provider 里调大 stream_max_retries。

1. **看报错里的 url 是不是 CCSub**：error sending request for url (...) 括号里应该是 https://www.ccsub.net/api/v1/responses。如果是别的地址，说明配置被改写或没生效，先修 ~/.codex/config.toml，再看下面的步骤。
2. **排除本地代理的干扰**：检查终端里的 HTTPS_PROXY / HTTP_PROXY / ALL_PROXY，以及代理软件的 TUN、全局模式。CCSub 在国内可以直连，给 ccsub.net 设置直连或 NO_PROXY，流式长连接就不会被代理节点中途切断。
3. **调大重试次数，缩短单轮时长**：在 [model_providers.ccsub] 里设置 stream_max_retries（默认 5）和 request_max_retries（默认 4）；单轮生成超过 5 分钟会被服务端截断，可以把 model_reasoning_effort 调低一档，或把大任务拆成几步。

详细排查：[Codex 报 stream disconnected before completion 怎么解决](https://www.ccsub.net/zh/errors/codex-stream-disconnected?utm_source=github-guide)

---

返回：[目录](../README.md)
