defmodule Server.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # port = System.get_env("PORT") || raise "missing $PORT environment variable"
    port = 4040

    children = [
      worker(Task, [Server, :accept, [port]]),
      supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]]),
      worker(Server.Components.Chats, [])
    ]

    opts = [strategy: :one_for_one, name: Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
