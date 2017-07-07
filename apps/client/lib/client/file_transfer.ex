defmodule Client.FileTransfer do
  def send(chunks, host, port) do
    options = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect(host, port, options)

    chunks
    |> Stream.map(&Base.encode64/1)
    |> Enum.map(fn chunk ->
      :ok = :gen_tcp.send(socket, chunk <> "\r\n")
    end)

    :ok = :gen_tcp.shutdown(socket, :read_write)
  end

  def receive(caller_pid, chunks_count) do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(0, options)

    socket_pair = :inet.sockname(socket)
    send(caller_pid, socket_pair)

    {:ok, sender} = :gen_tcp.accept socket
    # TODO: verify that the sender has connected?

    file = receive_file(sender, chunks_count)
    :ok = :gen_tcp.shutdown(sender, :read_write)
    file
  end

  defp receive_file(sender, chunks_count) do
    Stream.repeatedly(fn ->
      {:ok, line} = :gen_tcp.recv(sender, 0)
      line |> String.trim |> Base.decode64!
    end)
    |> Enum.take(chunks_count)
    |> Enum.join
  end
end
