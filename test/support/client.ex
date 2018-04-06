defmodule IRC.Client do
  def new(port) do
    {:ok, socket} = :gen_tcp.connect('localhost', port, [:binary, packet: :line])
    socket
  end

  def nick(socket, nick) do
    socket |> write("NICK #{nick}")
  end

  def user(socket, login, first_name, last_name) do
    socket |> write("USER #{login} * * :#{first_name} #{last_name}")
  end

  def register(socket, nick, first_name, last_name) do
    socket
    |> nick(nick)
    |> user(nick, first_name, last_name)
  end

  def privmsg(socket, msg) do
    socket |> write(msg)
  end

  def write(socket, msg) do
    :gen_tcp.send(socket, "#{msg}\r\n")
    socket
  end
end
