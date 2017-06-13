defmodule Client.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    host = 'localhost'
    port = 4040

    children = [
      worker(Client, [[host: host, port: port]]),
      supervisor(Task.Supervisor, [[name: :tasks_supervisor]])
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
