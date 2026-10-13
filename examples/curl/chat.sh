#!/usr/bin/env bash
# 简单对话请求
# 用法：export MOLYEYE_API_KEY="sk-..." && bash chat.sh
curl -s https://api.molyeye.com/v1/chat/completions \
  -H "Authorization: Bearer $MOLYEYE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "messages": [{"role": "user", "content": "用一句话介绍你自己"}]
  }'
