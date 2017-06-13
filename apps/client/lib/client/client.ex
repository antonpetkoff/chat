defmodule Client do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    host = args[:host]
    port = args[:port]
    options = [:binary, active: true, packet: :line]

    Logger.info "Client connecting to #{host}@#{port}..."
    {:ok, server} = :gen_tcp.connect(host, port, options)

    Logger.info "Client connected to #{host}@#{port}"
    {:ok, %{socket: server, from: nil}}
  end

  def execute(command) do
    GenServer.call(__MODULE__, {:execute, command})
  end

  def handle_info({:tcp, socket, msg}, %{socket: socket} = state) do
    Logger.info "Received #{msg}"
    GenServer.reply(state.from, msg)
    {:noreply, state}
  end

  def handle_call({:execute, command}, from, %{socket: socket} = state) do
    :ok = :gen_tcp.send(socket, command)
    Logger.info "Sent #{command}"
    # TODO: we could use a :queue to store "from" for each request (command)
    #       but the client is just a single process and "from" is always the same
    {:noreply, %{state | from: from}}
  end
end
