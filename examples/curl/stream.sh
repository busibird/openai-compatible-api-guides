#!/usr/bin/env bash
# 流式输出：一边生成一边返回
# 用法：export MOLYEYE_API_KEY="sk-..." && bash stream.sh
curl -s -N https://api.molyeye.com/v1/chat/completions \
  -H "Authorization: Bearer $MOLYEYE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "stream": true,
    "messages": [{"role": "user", "content": "从 1 数到 5"}]
  }'
