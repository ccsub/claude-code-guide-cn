#!/usr/bin/env bash
# 中转站连通性自检：检查本机代理、模型列表、Anthropic 协议、OpenAI 协议四项，按状态码给出下一步。
# 只依赖 curl。会发两条极短的请求（max_tokens=16），产生几个 Token 的费用。
#
# 用法：
#   RELAY_API_KEY="sk-你的密钥" bash scripts/check-relay.sh
#
# 可选变量：
#   RELAY_BASE_URL         Anthropic 协议地址（Claude Code 里 ANTHROPIC_BASE_URL 填的那个），默认 https://www.ccsub.net
#   RELAY_OPENAI_BASE_URL  OpenAI 兼容地址（Codex / Cursor 里填的那个），默认 $RELAY_BASE_URL/api/v1
#   RELAY_CLAUDE_MODEL     测 Anthropic 协议用的型号，默认 claude-sonnet-5
#   RELAY_OPENAI_MODEL     测 OpenAI 协议用的型号，默认 gpt-5.5
#   没设 RELAY_API_KEY 时，依次尝试 ANTHROPIC_AUTH_TOKEN、ANTHROPIC_API_KEY、OPENAI_API_KEY。

set -u

BASE="${RELAY_BASE_URL:-https://www.ccsub.net}"
BASE="${BASE%/}"
OPENAI_BASE="${RELAY_OPENAI_BASE_URL:-$BASE/api/v1}"
OPENAI_BASE="${OPENAI_BASE%/}"
KEY="${RELAY_API_KEY:-${ANTHROPIC_AUTH_TOKEN:-${ANTHROPIC_API_KEY:-${OPENAI_API_KEY:-}}}}"
CLAUDE_MODEL="${RELAY_CLAUDE_MODEL:-claude-sonnet-5}"
OPENAI_MODEL="${RELAY_OPENAI_MODEL:-gpt-5.5}"

if ! command -v curl >/dev/null 2>&1; then
  echo "没找到 curl，请先安装。" >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

mask() {
  local k="$1"
  if [ "${#k}" -le 12 ]; then echo "(已设置，长度 ${#k})"; else echo "${k:0:6}…${k: -4}（长度 ${#k}）"; fi
}

# 根据状态码和返回内容给出提示
hint() {
  local code="$1"
  if head -c 200 "$TMP" | grep -qi "<!doctype html\|<html"; then
    echo "     返回的是网页而不是接口数据：地址的路径写错了（多了或少了 /v1、/api/v1）。"
    return
  fi
  case "$code" in
    200) ;;
    3*) echo "     被重定向了：地址多半写错了（多了或少了 /v1、/api/v1，或者用了 http 而不是 https）。" ;;
    000) echo "     请求没发出去：检查网络、DNS，以及上面列出的代理变量是否指向了没开的代理。" ;;
    401|403) echo "     Key 不对、没带上或已被禁用：到中转站控制台重新复制完整 Key，确认它是启用状态。" ;;
    402) echo "     余额不足，或当天额度已用完。" ;;
    404) echo "     路径或型号不存在：先核对地址，再核对型号 ID（用模型列表里的 id 原样填写）。" ;;
    429) echo "     请求太频繁或并发太多：等一会儿再试。" ;;
    5*) echo "     中转站或上游暂时出错：等一两分钟重试；一直这样就带上时间和报错原文联系客服。" ;;
    *) echo "     未预期的状态码，请看下面的返回内容。" ;;
  esac
}

show_body() {
  local snippet
  # 返回网页时不打印正文（太长，提示里已经说明了）
  if head -c 200 "$TMP" | grep -qi "<!doctype html\|<html"; then return; fi
  snippet="$(head -c 300 "$TMP" | tr '\n' ' ')"
  [ -n "$snippet" ] && echo "     返回：$snippet"
}

echo "== 中转站自检 =="
echo "  Anthropic 地址：$BASE"
echo "  OpenAI 地址：  $OPENAI_BASE"
if [ -z "$KEY" ]; then
  echo "  Key：未设置。请用 RELAY_API_KEY=\"sk-...\" 运行。" >&2
  exit 1
fi
echo "  Key：$(mask "$KEY")"
echo

echo "[1/4] 本机代理变量"
found=0
for v in HTTPS_PROXY https_proxy HTTP_PROXY http_proxy ALL_PROXY all_proxy NO_PROXY no_proxy; do
  if [ -n "${!v:-}" ]; then echo "     $v=${!v}"; found=1; fi
done
if [ "$found" = 0 ]; then
  echo "     没有设置代理变量。"
else
  echo "     如果代理没开却设了这些变量，Claude Code 会报 Connection error；可以给中转站域名加 NO_PROXY。"
fi
echo

echo "[2/4] 模型列表  GET $OPENAI_BASE/models"
code=$(curl -sS -o "$TMP" -w "%{http_code}" -m 20 "$OPENAI_BASE/models" -H "Authorization: Bearer $KEY" 2>/dev/null)
code="${code:-000}"
if [ "$code" = "200" ]; then
  n=$(grep -o '"id"' "$TMP" | wc -l | tr -d ' ')
  echo "  ✓ HTTP 200，共 $n 个型号"
  if ! grep -q "\"$CLAUDE_MODEL\"" "$TMP"; then echo "     提示：列表里没找到 ${CLAUDE_MODEL}，可以用 RELAY_CLAUDE_MODEL 换一个。"; fi
  if ! grep -q "\"$OPENAI_MODEL\"" "$TMP"; then echo "     提示：列表里没找到 ${OPENAI_MODEL}，可以用 RELAY_OPENAI_MODEL 换一个。"; fi
else
  echo "  ✗ HTTP $code"; hint "$code"; show_body
fi
echo

echo "[3/4] Anthropic 协议  POST $BASE/v1/messages  （Claude Code 走这条）"
t=$(curl -sS -o "$TMP" -w "%{http_code} %{time_total}" -m 120 -X POST "$BASE/v1/messages" \
  -H "Authorization: Bearer $KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{\"model\":\"$CLAUDE_MODEL\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" 2>/dev/null)
code="${t%% *}"; code="${code:-000}"; secs="${t#* }"
if [ "$code" = "200" ] && grep -q '"type":"message"\|"id":"msg_' "$TMP"; then
  echo "  ✓ HTTP 200，用时 ${secs}s"
else
  echo "  ✗ HTTP ${code}（用时 ${secs}s）"; hint "$code"; show_body
fi
echo

echo "[4/4] OpenAI 协议  POST $OPENAI_BASE/chat/completions  （Cursor、Cline 等走这条）"
t=$(curl -sS -o "$TMP" -w "%{http_code} %{time_total}" -m 120 -X POST "$OPENAI_BASE/chat/completions" \
  -H "Authorization: Bearer $KEY" \
  -H "content-type: application/json" \
  -d "{\"model\":\"$OPENAI_MODEL\",\"max_tokens\":16,\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" 2>/dev/null)
code="${t%% *}"; code="${code:-000}"; secs="${t#* }"
if [ "$code" = "200" ] && grep -q '"choices"' "$TMP"; then
  echo "  ✓ HTTP 200，用时 ${secs}s"
else
  echo "  ✗ HTTP ${code}（用时 ${secs}s）"; hint "$code"; show_body
fi
echo
echo "完成。四项都是 ✓ 说明地址和 Key 都没问题；工具里还报错的话，问题在工具自己的配置上，对照 docs/ 里对应工具的说明检查。"
