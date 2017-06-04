defmodule Server do
  require Logger

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
    socket |> read_line() |> write_line(socket)
    serve socket
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
