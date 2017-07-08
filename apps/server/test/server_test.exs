defmodule ServerTest do
  use ExUnit.Case

  defp connect_client do
    host = 'localhost'
    port = 4040
    options = [:binary, active: false, packet: :line]
    {:ok, client} = :gen_tcp.connect(host, port, options)
    client
  end

  defp recv(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    recv(socket)
  end

  defp disconnect_client(socket) do
    :gen_tcp.shutdown(socket, :read_write)
  end

  defp register(client, username) do
    assert send_and_recv(client, "user #{username}\r\n") ==
      "200 ok #{username} successfully registerred\r\n"
  end

  defp list(client, usernames) do
    usernames = Enum.join(usernames, " ")
    assert send_and_recv(client, "list\r\n") == "200 ok #{usernames}\r\n"
  end

  setup do
    :ok = Application.start(:server)

    clients = Stream.repeatedly(&connect_client/0) |> Enum.take(3)

    on_exit fn ->
      Enum.map(clients, &disconnect_client/1)
      Application.stop(:server)
    end

    {:ok, clients: clients}
  end

  describe "users" do
    test "can register", %{clients: [client | _]} do
      username = "a"
      register(client, username)
      list(client, [username])
    end
  end

  describe "messages" do
    test "can be sent from user to user", %{clients: [client1, client2 | _]} do
      username1 = "a"
      username2 = "b"
      register(client1, username1)
      register(client2, username2)

      message = "hello world"
      assert send_and_recv(client1, "send_to #{username2} #{message}\r\n") ==
        "200 ok message to #{username2} sent successfully\r\n"
      assert recv(client2) == "300 msg_from #{username1} #{message}\r\n"
    end
  end

  describe "files" do

  end
end
