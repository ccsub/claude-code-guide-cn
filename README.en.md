# Using Claude Code from China: API Relay Setup Guide

Claude Code, Codex CLI, Cursor and Cline work fine from mainland China if you point them at an **API relay** (also called a Claude API proxy). You don't modify the tools. You change two settings: the base URL, which becomes the relay's address, and the key, which becomes the relay's key.

This repo collects the exact settings for common tools, the base URL rules, and fixes for the errors people hit most.

- Examples use [CCSub](https://www.ccsub.net/en?utm_source=github-guide), which maintains this repo.
- Any relay that speaks the Anthropic or OpenAI protocol works the same way. Swap in its URL and key.
- Every setting here is an officially supported option of the tool (environment variables or config files). No patched clients.

[中文](README.md)

## The one rule for base URLs

Tools speak one of two protocols: **Anthropic Messages** (`/v1/messages`) or **OpenAI-compatible** (`/chat/completions`, `/responses`). The only question is whether the tool appends `/v1` itself.

- **Tools that append it** (Claude Code; Zed `anthropic_compatible`; the Anthropic option in Cline and Cherry Studio): enter the bare domain, **without** `/v1`.
- **Tools that don't** (Codex CLI, Cursor, Continue, OpenCode, Kilo Code): include the version path. On CCSub that is `/api/v1`.

Most "can't connect", 404 and "got an HTML page back" errors come from getting this wrong.

| Tool | Protocol | Base URL (CCSub example) | Where the key goes | Common pitfall |
|---|---|---|---|---|
| Claude Code | Anthropic | `https://www.ccsub.net` | `ANTHROPIC_AUTH_TOKEN` | No `/v1`, no trailing slash |
| Codex CLI | OpenAI Responses | `https://www.ccsub.net/api/v1` | the variable named in `env_key` | New versions ignore `OPENAI_BASE_URL`; use `~/.codex/config.toml` |
| Cursor | OpenAI | `https://www.ccsub.net/api/v1` | Settings → Models → OpenAI API Key | Turn on "Use OpenAI API Key"; model names can't start with `claude-` |
| Cline | Both | Anthropic: `https://www.ccsub.net` · OpenAI Compatible: `https://www.ccsub.net/api/v1` | API Key | Tick "Use custom base URL" for Anthropic |
| OpenCode | Both | `https://www.ccsub.net/api/v1` | `apiKey` or `/connect` | `/v1` is required for both protocols |
| Continue | Both | `https://www.ccsub.net/api/v1` | `apiKey` | `/v1` is required even with `provider: anthropic` |
| Zed | Both | anthropic_compatible: `https://www.ccsub.net` · openai_compatible: `https://www.ccsub.net/api/v1` | UI or env var | |

## Claude Code in three minutes

```bash
# macOS / Linux (use ~/.bashrc for bash)
echo 'export ANTHROPIC_BASE_URL="https://www.ccsub.net"' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-your-key"' >> ~/.zshrc
source ~/.zshrc
claude
```

```powershell
# Windows PowerShell: then close and reopen every terminal
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'https://www.ccsub.net', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'sk-your-key', 'User')
```

You can also put both values in the `env` block of `~/.claude/settings.json`. Values there take precedence over your shell.

To verify, run `/status` inside Claude Code. The `Anthropic base URL` line should show your relay's address.

## Codex CLI

New Codex versions ignore `OPENAI_BASE_URL`. Add a custom provider to `~/.codex/config.toml`. Project-level `config.toml` files can't set providers.

```toml
model = "gpt-5.5"
model_provider = "ccsub"

[model_providers.ccsub]
name = "CCSub"
base_url = "https://www.ccsub.net/api/v1"
wire_api = "responses"
env_key = "OPENAI_API_KEY"
```

## Self-check script

```bash
RELAY_API_KEY="sk-your-key" bash scripts/check-relay.sh
```

The script checks four things in order: proxy variables, the model list, the Anthropic protocol and the OpenAI protocol. For each failure it explains what the status code means. It sends two tiny requests (`max_tokens` 16).

## More

- Per-tool guides (Chinese): [docs/](docs/)
- Ready-to-copy config files: [examples/](examples/)
- Error reference (Chinese): [docs/errors.md](docs/errors.md)
- English tutorials on the CCSub site: [integrations](https://www.ccsub.net/en/integrations?utm_source=github-guide) · [error fixes](https://www.ccsub.net/en/errors?utm_source=github-guide)

## About CCSub

[CCSub](https://www.ccsub.net/en?utm_source=github-guide) is a Claude Code API relay. One key works with both the Anthropic and the OpenAI-compatible APIs, no VPN is needed from mainland China, you can pay with Alipay or USDT, and ¥1 buys $1 of credit.

## License

[MIT](LICENSE)
