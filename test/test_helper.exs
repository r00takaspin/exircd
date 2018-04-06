defmodule IRC.Support.UserFactory do
  def create_user() do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :line, active: false, reuseaddr: true])

    IRC.UserRegistry.find_or_create_by_socket(socket)
  end
end

{:ok, files} = File.ls("./test/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end

ExUnit.start()
