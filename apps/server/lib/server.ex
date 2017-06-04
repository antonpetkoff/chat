defmodule Server do
  require Logger
  alias Server.Command

  def accept(port) do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, options)
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor socket
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept socket

    {:ok, pid} = Task.Supervisor.start_child(Server.TaskSupervisor, fn ->
      serve client
    end)
    :ok = :gen_tcp.controlling_process(client, pid)

    loop_acceptor socket
  end

  defp serve(socket) do
    response = case read_line socket do
      {:ok, data} -> case Command.parse data do
        {:ok, command} -> Command.run command
        {:error, _} = error -> error
      end
      {:error, _} = error -> error
    end

    write_line(socket, response)
    serve socket
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, message}) do
    :gen_tcp.send(socket, message)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
