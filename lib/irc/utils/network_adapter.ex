defmodule IRC.Utils.NetworkAdapter do
  def get_ip(socket) do
    {:ok, {address, _}} = :inet.peername(socket)
    :inet_parse.ntoa(address)
  end
end