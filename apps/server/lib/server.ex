defmodule Server do
  require Logger
  alias Server.Request

  def accept(port) do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, options)
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor socket
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept socket

    Logger.info "Accepted request"
    client |> :inet.peername |> IO.inspect

    {:ok, pid} = Task.Supervisor.start_child(Server.TaskSupervisor, fn ->
      handle_socket client
    end)
    # :ok = :gen_tcp.controlling_process(client, pid) # handle {:error, :badarg}
    :gen_tcp.controlling_process(client, pid)

    loop_acceptor socket
  end

  defp handle_socket(socket) do
    response = with {:ok, line} <- read_line(socket),
                    do: serve(line)

    write_line(socket, response)
    handle_socket socket
  end

  defp serve(line) do
    result = with {:ok, request} <- Request.parse(line),
                  do: Request.serve(request)
    Response.create(result)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, message}) do
    :gen_tcp.send(socket, message)
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
