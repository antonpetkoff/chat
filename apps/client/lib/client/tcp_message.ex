defmodule Client.TCPMessage do
  def parse(line) do
    [code, status, body] = line
    |> String.trim
    |> String.split(" ", parts: 3)

    do_parse(code, status, body)
  end

  def do_parse("100", "err", reason) do
    {:error, {:response, reason}}
  end

  def do_parse("200", "ok", body) do
    {:ok, {:response, body}}
  end

  def do_parse("300", "msg_from", body) do
    [username, message] = String.split(body, " ", parts: 2)
    {:ok, {:message, {:message_from, message, username}}}
  end

  def do_parse("501", "rcv_file", body) do
    [username, filename, chunk_size] = String.split(body, " ", parts: 3)
    {chunk_size, _} = Integer.parse chunk_size
    {:ok, {:message, {:receive_file, username, filename, chunk_size}}}
  end

  def do_parse(code, status, body) do
    {:error, "#{code} #{status} #{body}"}
  end
end