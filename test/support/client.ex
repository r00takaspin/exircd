defmodule IRC.Client do
  def nick(socket, nick) do
    socket |> write("NICK #{nick}")
  end

  def user(socket, login, first_name, last_name) do
    socket |> write("USER #{login} * * :#{first_name} #{last_name}")
  end

  defp write(socket, msg) do
    :gen_tcp.send(socket, "#{msg}\r\n")
    socket
  end
end
