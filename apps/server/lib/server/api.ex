defmodule Server.API do
  alias Server.Components.Chats

  def register(user), do: Chats.register(user)
end
