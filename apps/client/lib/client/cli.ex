defmodule Client.CLI do
  alias Client.CLI.Parser
  alias Client.API

  def interpret do
    interaction = with input <- IO.gets("|> "),
                       {:ok, command} <- Parser.parse(input),
                       do: API.handle(command, [])

    case interaction do
      {:ok, result} -> IO.puts "ok: #{result}"
      {:error, :invalid} -> IO.puts "invalid command"
      {:error, :not_implemented} -> IO.puts "not implemented"
      {:error, reason} -> IO.puts "error: #{reason}"
    end

    interpret()
  end

end