defmodule IRC.Support.UserFactory do
  def create_user() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :line, active: false, reuseaddr: true])

    IRC.UserRegistry.find_or_create_by_socket(socket)
  end
end

ExUnit.start()
