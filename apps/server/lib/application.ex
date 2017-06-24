defmodule Server.Application do
  use Application

  @default_port 4040

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {port, _} = Application.get_env(:server, :port, @default_port)
    |> Integer.parse

    children = [
      worker(Task, [Server, :accept, [port]]),
      supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]]),
      worker(Server.Components.Connections, []),
      worker(Server.Components.Broker, []),
      worker(Server.Components.Chats, []),
      worker(Server.Components.P2P, [])
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
