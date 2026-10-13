// Responses 接口写法。
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.molyeye.com/v1",
  apiKey: process.env.MOLYEYE_API_KEY,
});

const resp = await client.responses.create({
  model: "gpt-5.5",
  input: "用一句话介绍你自己",
});
console.log(resp.output_text);
