defmodule Client.FileTransfer do
  def receive(caller_pid, chunks_count) do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(0, options)

    socket_pair = :inet.sockname(socket)
    send(caller_pid, socket_pair)

    {:ok, sender} = :gen_tcp.accept socket
    # TODO: verify that the sender has connected?
    receive_chunk(sender, chunks_count, [])
  end

  defp receive_chunk(socket, 0, received_chunks) do
    received_file = received_chunks
    |> Enum.reverse
    |> Enum.map(&Base.decode64!/1)
    |> Enum.join

    now = DateTime.utc_now |> DateTime.to_string
    IO.puts "#{now}: file received successfully:\n#{received_file}"

    :ok = :gen_tcp.shutdown(socket, :read_write)
  end

  defp receive_chunk(socket, chunks_count, received_chunks) do
    {:ok, line} = :gen_tcp.recv(socket, 0)
    receive_chunk(socket, chunks_count - 1, [String.trim(line) | received_chunks])
  end

  def send(chunks, host, port) do
    options = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect(host, port, options)
    send_chunk(socket, chunks)
  end

  defp send_chunk(socket, []) do
    :ok = :gen_tcp.shutdown(socket, :read_write)
  end

  defp send_chunk(socket, [chunk | chunks]) do
    :ok = :gen_tcp.send(socket, chunk <> "\r\n")
    send_chunk(socket, chunks)
  end
end
