// 简单对话请求。先 npm install，再设置环境变量 MOLYEYE_API_KEY。
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.molyeye.com/v1",
  apiKey: process.env.MOLYEYE_API_KEY,
});

const resp = await client.chat.completions.create({
  model: "gpt-5.5",
  messages: [{ role: "user", content: "用一句话介绍你自己" }],
});
console.log(resp.choices[0].message.content);
console.log("实际模型：", resp.model, "| 用量：", resp.usage.total_tokens, "tokens");
