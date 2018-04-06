defmodule IRC.Support.UserFactory do
  alias IRC.User

  def create_user() do
    socket = init_socket()

    IRC.UserRegistry.find_or_create_by_socket(socket)
  end

  def registered_user(nick) do
    {:ok, user} = create_user()
    User.nick(user, nick)
    User.user(user, "fed", "*", "Fedya M")
    user
  end

  defp init_socket() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :line, active: false, reuseaddr: true])
    socket
  end
end

{:ok, files} = File.ls("./test/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end

ExUnit.start()
