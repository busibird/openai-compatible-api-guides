#!/usr/bin/env bash
# Responses 接口（Codex CLI 等工具用的就是它）
# 用法：export MOLYEYE_API_KEY="sk-..." && bash responses.sh
curl -s https://api.molyeye.com/v1/responses \
  -H "Authorization: Bearer $MOLYEYE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-5.5",
    "input": "用一句话介绍你自己"
  }'
