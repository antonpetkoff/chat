defmodule Server.Components.Chats do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_user(user) do
    GenServer.call(__MODULE__, {:register_user, user})
  end

  def list_users do
    GenServer.call(__MODULE__, :list_users)
  end

  def init(_) do
    # TODO: create User and ChatHistory models
    users = %{}
    {:ok, users}
  end

  def handle_call({:register_user, user}, _from, state) do
    case Map.has_key?(state, user) do
      true -> {:reply, {:error, :already_taken}, state}
      false -> {:reply, :ok, Map.put(state, user, %{})}
    end
  end

  def handle_call(:list_users, _from, state) do
    {:reply, {:ok, Map.keys state}, state}
  end
end
