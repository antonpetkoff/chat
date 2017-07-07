defmodule Client.CLI do
  alias Client.CLI.Parser
  alias Client.API

  def notify(message) do
    now = DateTime.utc_now |> DateTime.to_string
    IO.puts "#{now}: #{message}"
  end

  def start do
    register()
    interpret()
  end

  defp register do
    username = IO.gets("enter your username |> ")
    case API.handle({:register, username}, []) do
      {:ok, result} -> IO.puts "ok: #{result}"
      {:error, reason} ->
        IO.puts "error: #{reason}"
        register()
    end
  end

  defp interpret do
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