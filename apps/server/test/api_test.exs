defmodule ServerAPITest do
  use ExUnit.Case
  # doctest Server.API
  alias Server.API

  defp connect_client do
    host = 'localhost'
    port = 4040
    options = [:binary, active: true, packet: :line]
    :gen_tcp.connect(host, port, options)
  end

  defp call(command, client_socket) do
    API.call(command, [from_socket: client_socket])
  end

  setup do
    Application.stop(:server)
    :ok = Application.start(:server)
    {:ok, client} = connect_client()
    {:ok, client: client}
  end

  describe "users" do
    test "can register", %{client: client} do
      assert {:ok, {:register, "dingo"}} == call({:register, "dingo"}, client)
    end

    test "cannot register twice from one socket", %{client: client} do
      assert {:ok, {:register, "dingo"}} == call({:register, "dingo"}, client)
      assert {:error, {:register, "dingo", "already taken"}} == call({:register, "dingo"}, client)
    end

    test "can unregister", %{client: client} do
      assert {:ok, {:register, "dingo"}} == call({:register, "dingo"}, client)
      assert {:ok, {:unregister, "dingo"}} == call(:unregister, client)
    end
  end

  describe "messages" do

  end

  describe "files" do

  end
end
