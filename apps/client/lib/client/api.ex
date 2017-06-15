defmodule Client.API do
  def handle({:message_from, message, username}) do
    # TODO: Store message in chat history
    :ok
  end

  def handle({:send_file, username, filename}) do
    IO.puts "i must read #{filename}"
    :ok
  end

  def handle(_) do
    {:error, :not_implemented}
  end
end