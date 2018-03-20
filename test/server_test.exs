defmodule IRC.ServerTest do
  use ExUnit.Case

  @port 6667

  setup do
    {:ok, pid} = ExIRCd.start([], [])
    {:ok, socket} = :gen_tcp.connect('localhost', @port, [:binary, packet: :line, active: false])

    on_exit fn -> :gen_tcp.close(socket); Process.exit(pid, :down) end

    %{socket: socket}
  end

  test "Basic registration scanario: nick -> user", %{socket: socket} do
    :gen_tcp.send(socket, "NICK voldemar\r\n")
    :gen_tcp.send(socket, "USER voldemar * * :Voldemar Duletskiy\r\n")

    assert_welcone(socket)
  end

  test "Basic registration scanario: user -> nick", %{socket: socket} do
    :gen_tcp.send(socket, "USER voldemar * * :Voldemar Duletskiy\r\n")
    :gen_tcp.send(socket, "NICK voldemar\r\n")

    assert_welcone(socket)
  end

  def assert_welcone(socket) do
    read_assert(socket, "1 Welcome to the Internet Relay Network voldemar!voldemar@127.0.0.1>\r\n")
    read_assert(socket, "2 Your host is Ironclad, running version 0.0.1 alpha\r\n")
    read_assert(socket, "3 This server was created Sat Mar 3 2018 at 03:57:37 EDT\r\n")
    read_assert(socket, "4 Ironclad 0.0.1 alpha aiwroOs asdasdasdasd\r\n")
  end

  def read_assert(socket, msg) do
    {:ok, res} = :gen_tcp.recv(socket, 0)

    assert res == msg
  end
end
