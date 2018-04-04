defmodule IRC.ServerTest do
  use ExUnit.Case

  @port 6667

  setup_all do
    {:ok, _pid} = ExIRCd.start([], [])
    :ok
  end

  setup do
    socket = new_client()
    %{socket: socket}
  end

  @nick "voldemar"
  @login @nick

  test "Basic registration scanario: nick -> user", %{socket: socket} do
    register(socket)
    assert_welcone(socket)

    :gen_tcp.close(socket)
  end

  test "Basic registration scanario: user -> nick", %{socket: socket} do
    :gen_tcp.send(socket, "USER voldemar * * :Voldemar Duletskiy\r\n")
    :gen_tcp.send(socket, "NICK voldemar\r\n")

    assert_welcone(socket)

    :gen_tcp.close(socket)
  end

  test "nick already exists" do
    socket = new_client()
    register(socket)

    # TODO: remove sleep
    :timer.sleep(50)

    socket1 = new_client()

    :gen_tcp.send(socket1, "NICK #{@nick}\r\n")

    read_assert(socket1, "433 <#{@nick}> :Nickname is already in use\r\n")

    :gen_tcp.close(socket1)
  end

  def new_client() do
    {:ok, socket} = :gen_tcp.connect('localhost', @port, [:binary, packet: :line, active: false])
    socket
  end

  def register(socket) do
    :gen_tcp.send(socket, "NICK #{@nick}\r\n")
    :gen_tcp.send(socket, "USER #{@login} * * :Voldemar Duletskiy\r\n")
  end

  def assert_welcone(socket) do
    read_assert(socket, "1 Welcome to the Internet Relay Network #{@nick}!#{@login}@127.0.0.1>\r\n")
    read_assert(socket, "2 Your host is Ironclad, running version 0.0.1 alpha\r\n")
    read_assert(socket, "3 This server was created Sat Mar 3 2018 at 03:57:37 EDT\r\n")
    read_assert(socket, "4 Ironclad 0.0.1 alpha aiwroOs asdasdasdasd\r\n")
  end

  def read_assert(socket, msg) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, res} -> assert res == msg
      msg -> IO.inspect(msg)
    end
  end
end
