defmodule Client do
  require Logger
  use GenServer

  @initial_state %{socket: nil}

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end

  def init(state) do
    options = [:binary, active: false, packet: :line]
    {:ok, server} = :gen_tcp.connect('localhost', 4040, options)

    Logger.info "Client connected"
    {:ok, %{state | socket: server}}
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
