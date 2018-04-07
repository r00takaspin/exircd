defmodule IRC.Support.Factory do
  alias IRC.{UserRegistry, User}

  def user() do
    socket = init_socket()

    UserRegistry.find_or_create_by_socket(socket)
  end

  def user(:registered, nick) do
    {:ok, user} = user()
    User.nick(user, nick)
    User.user(user, "fed", "*", "Fedya M")
    user
  end

  defp init_socket() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :line, reuseaddr: true])
    socket
  end
end