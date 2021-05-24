defmodule Converter do
  @elixir_prompt "iex> "
  @continue_prompt "...> "

  def convert_page(page) do
    file_path = "../getting-started/#{page}.markdown"

    File.read!(file_path)
    |> set_titel()
    |> then(fn content ->
      Regex.replace(
        ~r/```elixir\n(.+)\n```/Ums,
        content,
        fn _, code_block ->
          cleanup_code(code_block)
        end
      )
    end)
  end

  defp set_titel(content) do
    Regex.replace(~r/\A---.*title: ([[:print:]]+).*---/ms, content, "## \\1")
  end

  defp cleanup_code(code_block) do
    if String.contains?(code_block, @elixir_prompt) do
      code_block
      |> String.split("\n")
      |> Enum.reduce([], fn line, accu ->
        case line do
          @elixir_prompt <> rest -> accu ++ [rest]
          @continue_prompt <> rest -> List.update_at(accu, 0, &"#{&1}\n#{rest}")
          _ -> accu
        end
      end)
      |> IO.inspect()
      |> Enum.map(&"```elixir\n#{&1}\n```")
      |> Enum.join("\n")
    else
      "```\n#{code_block}\n```"
    end
  end
end

pages = ["basic-types"]

heading = "# Getting Started

```elixir
import IEx.Helpers
```
"

output =
  Enum.reduce(
    pages,
    heading,
    fn page, accu ->
      accu <> Converter.convert_page(page)
    end
  )

File.write!("getting-started.livemd", output)
