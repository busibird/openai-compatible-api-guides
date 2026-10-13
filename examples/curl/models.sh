#!/usr/bin/env bash
# 列出当前 Key 能用的模型
# 用法：export MOLYEYE_API_KEY="sk-..." && bash models.sh
curl -s https://api.molyeye.com/v1/models \
  -H "Authorization: Bearer $MOLYEYE_API_KEY"
