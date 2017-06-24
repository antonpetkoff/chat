defmodule Client.Application do
  use Application

  @default_host 'localhost'
  @default_port 4040

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    host = Application.get_env(:client, :server_host, @default_host)
    |> to_charlist
    {port, _} = Application.get_env(:client, :server_port, @default_port)
    |> Integer.parse

    children = [
      worker(Task, [Client.CLI, :interpret, []]),
      worker(Client, [[host: host, port: port]]),
      supervisor(Task.Supervisor, [[name: :tasks_supervisor]])
    ]

    opts = [strategy: :one_for_one, name: Client.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
