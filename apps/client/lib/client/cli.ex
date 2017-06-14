defmodule Client.CLI do
  alias Client.CLI.Parser

  def interpret do
    IO.gets("|> ") |> Parser.parse |> IO.inspect

    interpret()
  end

end