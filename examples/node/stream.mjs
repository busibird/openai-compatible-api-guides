// 流式输出：边生成边打印。
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.molyeye.com/v1",
  apiKey: process.env.MOLYEYE_API_KEY,
});

const stream = await client.chat.completions.create({
  model: "gpt-5.5",
  messages: [{ role: "user", content: "从 1 数到 5，每个数字一行" }],
  stream: true,
});
for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content ?? "");
}
process.stdout.write("\n");
