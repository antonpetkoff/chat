defmodule Server.Components.Chats do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register(user) do
    GenServer.call(__MODULE__, {:register, user})
  end

  def init(_) do
    # TODO: create User and ChatHistory models
    users = %{}
    {:ok, users}
  end

  def handle_call({:register, user}, _from, state) do
    case Map.has_key?(state, user) do
      true -> {:reply, {:error, :already_taken}, state}
      false -> {:reply, :ok, Map.put(state, user, %{})}
    end
  end
end
