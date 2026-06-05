#!/bin/bash
# OpenClaw Model Tester — via Telegram @kpihx_openclaw_bot
# Usage: test-all-models.sh [category]
# Categories: go, free, openrouter, all (default: all)

BOT_ID="8948919586"
WAIT_MODEL=3
WAIT_REPLY=35

send() { zsh -l -c "tg user send $BOT_ID \"$1\"" 2>/dev/null; }
read_reply() { zsh -l -c "tg user read $BOT_ID --limit 1" 2>/dev/null | grep -A3 "^  [0-9]"; }

test_model() {
    local model=$1
    local num=$2
    send "/new"; sleep 3
    send "/model $model"; sleep $WAIT_MODEL
    send "Reply ONLY: I am $model and I work."; sleep $WAIT_REPLY
    local reply=$(read_reply | grep "kpihx_openclaw_bot" | grep -v "went wrong\|Something")
    if [ -z "$reply" ]; then
        echo "$num. $model ❌"
    else
        echo "$num. $model ✅ $(echo $reply | sed 's/.*kpihx_openclaw_bot   //')"
    fi
}

category="${1:-all}"

if [ "$category" = "go" ] || [ "$category" = "all" ]; then
    echo "=== OPENCODE GO (12) ==="
    test_model "opencode-go/deepseek-v4-flash" "01"
    test_model "opencode-go/deepseek-v4-pro" "02"
    test_model "opencode-go/glm-5" "03"
    test_model "opencode-go/glm-5.1" "04"
    test_model "opencode-go/kimi-k2.5" "05"
    test_model "opencode-go/kimi-k2.6" "06"
    test_model "opencode-go/mimo-v2.5" "07"
    test_model "opencode-go/mimo-v2.5-pro" "08"
    test_model "opencode-go/minimax-m2.5" "09"
    test_model "opencode-go/minimax-m2.7" "10"
    test_model "opencode-go/qwen3.6-plus" "11"
    test_model "opencode-go/qwen3.7-max" "12"
fi

if [ "$category" = "free" ] || [ "$category" = "all" ]; then
    echo "=== OPENCODE ZEN FREE (3) ==="
    test_model "opencode/deepseek-v4-flash-free" "13"
    test_model "opencode/mimo-v2.5-free" "14"
    test_model "opencode/nemotron-3-super-free" "15"
fi

if [ "$category" = "openrouter" ] || [ "$category" = "all" ]; then
    echo "=== OPENROUTER ==="
    test_model "openrouter/auto" "16"
    test_model "openrouter/deepseek/deepseek-v4-flash:free" "17"
    test_model "openrouter/qwen/qwen3-coder:free" "18"
    test_model "openrouter/meta-llama/llama-3.3-70b-instruct:free" "19"
    test_model "openrouter/nousresearch/hermes-3-llama-3.1-405b:free" "20"
fi

echo "=== DONE ==="
