defmodule Server.API do
  alias Server.Components.Chats

  def register(user), do: Chats.register_user(user)

  def list, do: Chats.list_users
end
