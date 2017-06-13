defmodule Client do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    host = args[:host]
    port = args[:port]
    options = [:binary, active: false, packet: :line]

    Logger.info "Client connecting to #{host}@#{port}..."
    {:ok, server} = :gen_tcp.connect(host, port, options)

    Logger.info "Client connected to #{host}@#{port}"
    {:ok, %{socket: server}}
  end

  def execute(command) do
    GenServer.call(__MODULE__, {:execute, command})
  end

  def handle_call({:execute, command}, _form, %{socket: socket} = state) do
    :ok = :gen_tcp.send(socket, command)
    Logger.info "Sent #{command}"

    {:ok, response} = :gen_tcp.recv(socket, 0)
    Logger.info "Received #{response}"

    {:reply, {:ok, response}, state}
  end
end
