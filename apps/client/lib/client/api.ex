defmodule Client.API do
  alias Client.FileTransfer

  def handle({:message_from, message, username}, _) do
    # TODO: Store message in chat history
    :ok
  end

  def handle({:register, username}, _) do
    Client.execute("user #{username}\r\n")
    |> IO.inspect

    :ok
  end

  def handle(:list, _) do
    Client.execute("list\r\n")
    |> IO.inspect

    :ok
  end

  def handle({:send_message, username, message}, _) do
    Client.execute("send_to #{username} #{message}\r\n")
    |> IO.inspect

    :ok
  end

  def handle({:receive_file, username, filename, chunks_count}, [server_socket: socket]) do
    IO.puts "receive file #{filename} from #{username} of size #{chunks_count}"

    {:ok, file_transfer_socket} = FileTransfer.open_socket

    {:ok, _} = Task.Supervisor.start_child(:tasks_supervisor, fn ->
      FileTransfer.receive(file_transfer_socket, chunks_count)
    end)

    IO.puts "receiver opened socket and is listening at"
    file_transfer_socket |> :inet.sockname |> IO.inspect

    {:ok, socket_pair} = :inet.sockname file_transfer_socket
    socket_pair = socket_pair_to_string socket_pair

    :gen_tcp.send(socket, "open_socket #{username} #{filename} #{socket_pair}\r\n")
    :ok
  end

  def handle({:send_file, username, filename}, _) do
    chunks = read_chunks(filename, 512)
    chunks_count = Enum.count chunks
    IO.puts "#{chunks_count} chunks read"

    # chunks = Enum.map(chunks, &Base.encode64/1)

    # TODO:
    # ask server for where to send the files
    # connect to destination
    # send packages

    {:ok, [socket_pair]} = Client.execute("send_file_to #{username} #{filename} #{chunks_count}\r\n")
    {host, port} = socket_pair_from_string socket_pair
    options = [:binary, active: false, packet: :line]
    {:ok, socket} = :gen_tcp.connect(host, port, options)

    IO.puts "Connected to #{host}@#{port}"

    :ok
  end

  def handle(_, _) do
    {:error, :not_implemented}
  end

  defp read_chunks(filename, chunk_size) do
    {:ok, file} = File.open(filename, [:read])

    Stream.repeatedly(fn -> IO.binread(file, chunk_size) end)
    |> Enum.take_while(fn bytes -> not match?(:eof, bytes) end)
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