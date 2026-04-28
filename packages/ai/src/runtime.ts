export async function generateText(input: {
  instruction: string;
  prompt: string;
}): Promise<string> {
  const apiKey = process.env.OPENAI_API_KEY;
  const model = process.env.OPENAI_MODEL ?? "gpt-5-mini";

  if (!apiKey) {
    return [
      "[MOCK AI OUTPUT]",
      "",
      input.prompt.slice(0, 1600),
      "",
      "---",
      "This is mock mode because OPENAI_API_KEY is not configured."
    ].join("\n");
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model,
      input: [
        {
          role: "system",
          content: [{ type: "input_text", text: input.instruction }]
        },
        {
          role: "user",
          content: [{ type: "input_text", text: input.prompt }]
        }
      ]
    })
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`OpenAI request failed: ${response.status} ${errorText}`);
  }

  const json = await response.json();
  const directText =
    typeof json.output_text === "string" && json.output_text.trim().length > 0
      ? json.output_text.trim()
      : "";

  if (directText) return directText;

  const flattened = Array.isArray(json.output)
    ? json.output
        .flatMap((item: any) => (Array.isArray(item.content) ? item.content : []))
        .map((part: any) => {
          if (typeof part?.text === "string") return part.text;
          if (typeof part?.output_text === "string") return part.output_text;
          if (typeof part?.value === "string") return part.value;
          return "";
        })
        .filter(Boolean)
        .join("\n")
        .trim()
    : "";

  if (flattened) return flattened;

  throw new Error("OpenAI response did not include any text output.");
}
