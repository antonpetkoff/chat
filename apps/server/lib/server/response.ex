defmodule Server.Response do
  def create({:ok, {:register, user_name}}) do
    {:ok, "200 ok #{user_name} successfully registerred\r\n"}
  end

  def create({:error, {:register, user_name, reason}}) do
    {:ok, "100 err #{user_name} #{reason}\r\n"}
  end

  def create({:ok, {:unregister, user_name}}) do
    {:ok, "200 ok #{user_name} successfully unregistered\r\n"}
  end

  # TODO: pass the username?
  def create({:error, {:unregister, user_name, reason}}) do
    {:ok, "100 err #{user_name} #{reason}\r\n"}
  end

  def create({:ok, {:list_users, users}}) when is_list(users) do
    users = Enum.join(users, " ")
    {:ok, "100 ok #{users}\r\n"}
  end

  def create({:ok, {:send_message, username}}) do
    {:ok, "200 ok message to #{username} sent successfully\r\n"}
  end

  def create({:error, {:send_message, username}}) do
    {:ok, "100 err #{username} does not exists\r\n"}
  end

  def create({:ok, :broadcast_message}) do
    {:ok, "200 ok message sent successfully\r\n"}
  end

  def create({:error, :broadcast_message}) do
    {:ok, "100 err server error\r\n"}
  end

  def create({:error, :bad_request}) do
    {:ok, "400 err bad request\r\n"}
  end
end
