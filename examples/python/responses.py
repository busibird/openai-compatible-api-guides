"""Responses 接口写法（新版 openai 库推荐的接口）。"""
import os

from openai import OpenAI

client = OpenAI(
    base_url="https://api.molyeye.com/v1",
    api_key=os.environ["MOLYEYE_API_KEY"],
)

resp = client.responses.create(
    model="gpt-5.5",
    input="用一句话介绍你自己",
)
print(resp.output_text)
