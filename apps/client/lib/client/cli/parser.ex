defmodule Client.CLI.Parser do

  # TODO: Reuse Server.Request?

  @doc """
  Parses a command entered by the user.

  ## Examples

    iex> Client.CLI.Parser.parse "register my_user_name"
    {:ok, {:register, "my_user_name"}}

    iex> Client.CLI.Parser.parse "list"
    {:ok, :list}

    iex> Client.CLI.Parser.parse "send_to ivan hello, ivan"
    {:ok, {:send_message, "ivan", "hello, ivan"}}

    iex> Client.CLI.Parser.parse "send_file_to ivan filename"
    {:ok, {:send_file, "ivan", "filename"}}

    iex> Client.CLI.Parser.parse "send_all hello, everyone"
    {:ok, {:broadcast, "hello, everyone"}}

    iex> Client.CLI.Parser.parse "bye"
    {:ok, :unregister}

    iex> Client.CLI.Parser.parse "unknown command"
    {:error, :invalid}
  """
  def parse(command) do
    [directive | body] = command
    |> String.trim
    |> String.split(" ", parts: 2)

    do_parse(directive, body)
  end

  def do_parse("register", [username]) do
    {:ok, {:register, username}}
  end

  def do_parse("list", []) do
    {:ok, :list}
  end

  def do_parse("send_to", [body]) do
    [username, message] = String.split(body, " ", parts: 2)
    {:ok, {:send_message, username, message}}
  end

  def do_parse("send_file_to", [body]) do
    [username, filename] = String.split(body, " ", parts: 2)
    {:ok, {:send_file, username, filename}}
  end

  def do_parse("send_all", [message]) do
    {:ok, {:broadcast, message}}
  end

  def do_parse("bye", []) do
    {:ok, :unregister}
  end

  def do_parse(_, _) do
    {:error, :invalid}
  end

end