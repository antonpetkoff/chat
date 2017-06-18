defmodule Client.FileTransfer do
  def open_socket do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    :gen_tcp.listen(0, options)
  end

  def receive(socket, chunks_count) do
    IO.puts "waiting to accept..."

    {:ok, sender} = :gen_tcp.accept socket
    # TODO: :gen_tcp.accept always returns {:error, :closed}. But why?

    # TODO: verify that the sender has connected

    receive_chunk(sender, chunks_count)
  end

  defp receive_chunk(socket, 0) do
    :ok = :gen_tcp.shutdown(socket, :read_write)
  end

  defp receive_chunk(socket, chunks_count) do
    {:ok, line} = :gen_tcp.recv(socket, 0)
    IO.puts "Received chunk: #{line}"
    receive_chunk(socket, chunks_count - 1)
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
    # TODO: remember to end the chunk message with \r\n
    :ok = :gen_tcp.send(socket, chunk)
    send_chunk(socket, chunks)
  end
end
