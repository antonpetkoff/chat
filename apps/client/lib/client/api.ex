defmodule Client.API do
  alias Client.FileTransfer
  alias Client.CLI

  @chunk_size 512

  def handle({:message_from, message, username}, _) do
    CLI.notify("message from #{username}: #{message}")
    # TODO: Store message in chat history
    :ok
  end

  def handle({:register, username}, _) do
    Client.execute("user #{username}\r\n")
  end

  def handle(:unregister, _) do
    Client.execute("bye\r\n")
  end

  def handle(:list, _) do
    Client.execute("list\r\n")
  end

  def handle({:send_message, username, message}, _) do
    Client.execute("send_to #{username} #{message}\r\n")
  end

  def handle({:broadcast, message}, _) do
    Client.execute("send_all #{message}\r\n")
  end

  def handle({:receive_file, username, filename, chunks_count}, [server_socket: socket])
      when is_integer(chunks_count) do
    CLI.notify("receiving file #{filename} from #{username}...")

    self_pid = self()
    {:ok, _} = Task.Supervisor.start_child(:tasks_supervisor, fn ->
      file = FileTransfer.receive(self_pid, chunks_count)
      CLI.notify("file received successfully:\n#{file}")
    end)

    socket_pair = receive do
      {:ok, tuple} -> socket_pair_to_string tuple
    end

    :gen_tcp.send(socket, "open_socket #{username} #{filename} #{socket_pair}\r\n")
    :ok
  end

  def handle({:send_file, username, filename}, _) do
    chunks = File.stream!(filename, [:read], @chunk_size)
    chunks_count = Enum.count chunks

    {:ok, socket_pair} = Client.execute("send_file_to #{username} #{filename} #{chunks_count}\r\n")
    {host, port} = socket_pair_from_string socket_pair

    FileTransfer.send(chunks, host, port)
    {:ok, "file #{filename} sent successfully to #{username}"}
  end

  def handle(:help, _) do
    manual = """
    commands:
    send_to <user> <one_line_message>
    send_all <one_line_message>
    send_file_to <user> <filename>
    list
    bye
    """
    {:ok, manual}
  end

  def handle(_, _) do
    {:error, :not_implemented}
  end

  defp socket_pair_to_string({{a, b, c, d}, port}) when is_integer(port) do
    "#{a}.#{b}.#{c}.#{d}@#{port}"
  end

  defp socket_pair_from_string(string) do
    [host, port] = String.split(string, "@", parts: 2)
    {port, _} = Integer.parse port
    {to_charlist(host), port}
  end
end