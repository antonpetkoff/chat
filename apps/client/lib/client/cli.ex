defmodule Client.CLI do
  alias Client.CLI.Parser
  alias Client.API

  def interpret do
    interaction = with input <- IO.gets("|> "),
                       {:ok, command} <- Parser.parse(input),
                       do: API.handle(command, []) # TODO: use another module

    case interaction do
      :ok -> IO.puts "success"
      {:error, :invalid} -> IO.puts "invalid command"
      {:error, :not_implemented} -> IO.puts "not implemented"
    end

    interpret()
  end

end