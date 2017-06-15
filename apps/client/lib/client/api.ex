defmodule Client.API do
  def handle({:message_from, message, username}) do
    # TODO: Store message in chat history
    :ok
  end

  def handle({:send_file, username, filename}) do
    chunks = read_chunks(filename, 512)
    chunks_count = Enum.count chunks
    IO.puts "#{chunks_count} chunks read"

    chunks = Enum.map(chunks, &Base.encode64/1)
    IO.inspect chunks

    # TODO:
    # ask server for where to send the files
    # connect to destination
    # send packages

    Client.execute("send_file_to #{username} #{filename} #{chunks_count}\r\n")
    |> IO.inspect

    :ok
  end

  def handle(_) do
    {:error, :not_implemented}
  end

  defp read_chunks(filename, chunk_size) do
    {:ok, file} = File.open(filename, [:read])

    Stream.repeatedly(fn -> IO.binread(file, chunk_size) end)
    |> Enum.take_while(fn bytes -> not match?(:eof, bytes) end)
  end
end