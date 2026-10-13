"""流式输出：边生成边打印。"""
import os

from openai import OpenAI

client = OpenAI(
    base_url="https://api.molyeye.com/v1",
    api_key=os.environ["MOLYEYE_API_KEY"],
)

stream = client.chat.completions.create(
    model="gpt-5.5",
    messages=[{"role": "user", "content": "从 1 数到 5，每个数字一行"}],
    stream=True,
)
for chunk in stream:
    if chunk.choices and chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
print()
