defmodule Server.API do
  alias Server.Components.Chats

  @doc ~S"""
  Serves the given `request`.

  ## Examples

    iex> Server.API.call {:register, "dummy_user"}
    {:ok, {:register, "dummy_user"}}
  """
  def call({:register, user_name}) do
    case Chats.register_user(user_name) do
      :ok -> {:ok, {:register, user_name}}
      {:error, :already_taken} -> {:error, {:register, user_name, "already taken"}}
    end
  end

  def call(:list_users) do
    {:ok, users} = Chats.list_users
    {:ok, {:list_users, users}}
  end

  def call(_), do: {:error, :bad_request}
end
