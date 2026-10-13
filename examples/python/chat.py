"""简单对话请求。先 pip install openai，再设置环境变量 MOLYEYE_API_KEY。"""
import os

from openai import OpenAI

client = OpenAI(
    base_url="https://api.molyeye.com/v1",
    api_key=os.environ["MOLYEYE_API_KEY"],
)

resp = client.chat.completions.create(
    model="gpt-5.5",
    messages=[{"role": "user", "content": "用一句话介绍你自己"}],
)
print(resp.choices[0].message.content)
print("实际模型：", resp.model, "| 用量：", resp.usage.total_tokens, "tokens")
