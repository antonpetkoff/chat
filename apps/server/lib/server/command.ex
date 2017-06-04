defmodule Server.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

    iex> Server.Command.parse "user dummy_user\r\n"
    {:ok, {:register, "dummy_user"}}

    iex> Server.Command.parse "send_to dummy_user single line message\r\n"
    {:ok, {:send_message, "dummy_user", "single line message"}}

    iex> Server.Command.parse "send_all single line message\r\n"
    {:ok, {:broadcast_message, "single line message"}}

    iex> Server.Command.parse "list\r\n"
    {:ok, :list_users}

    iex> Server.Command.parse "send_file_to dummy_user file_name 128\r\n"
    {:ok, {:send_file, "dummy_user", "file_name", 128}}

    iex> Server.Command.parse "buy_flowers dummy_user\r\n"
    {:error, :unknown_command}
  """
  def parse(line) do
    [directive | body] = line
    |> String.trim
    |> String.split(" ", parts: 2)

    do_parse(directive, body)
  end

  defp do_parse("user", [user_name]) do
    case String.match?(user_name, ~r/[^\s]+/) do
      true -> {:ok, {:register, user_name}}
      false -> {:error, "No whitespaces allowed in user names"}
    end
  end

  defp do_parse("send_to", [body]) do
    [user_name, message] = String.split(body, " ", parts: 2)
    {:ok, {:send_message, user_name, message}}
  end

  defp do_parse("send_all", [message]) do
    {:ok, {:broadcast_message, message}}
  end

  defp do_parse("list", []) do
    {:ok, :list_users}
  end

  defp do_parse("send_file_to", [body]) do
    [user_name, file_name, packages_count] = String.split(body, " ", parts: 3)
    {packages_count, ""} = Integer.parse(packages_count)
    {:ok, {:send_file, user_name, file_name, packages_count}}
  end

  defp do_parse(_, _) do
    {:error, :unknown_command}
  end
end