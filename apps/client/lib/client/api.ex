defmodule Client.API do
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

    # TODO: create listening socket and send it back to server

    :gen_tcp.send(socket, "open_socket #{username} #{filename} localhost@42\r\n")
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

    Client.execute("send_file_to #{username} #{filename} #{chunks_count}\r\n")
    |> IO.inspect

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
end