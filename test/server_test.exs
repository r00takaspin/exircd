defmodule IRC.ServerTest do
  use ExUnit.Case

  alias IRC.Client

  @port 6667
  @nick "voldemar"
  @login @nick

  @welcome_messages [
    "1 Welcome to the Internet Relay Network #{@nick}!#{@login}@127.0.0.1>",
    "2 Your host is Ironclad, running version 0.0.1 alpha",
    "3 This server was created Sat Mar 3 2018 at 03:57:37 EDT",
    "4 Ironclad 0.0.1 alpha aiwroOs asdasdasdasd"
  ]

  def new_client() do
    {:ok, socket} = :gen_tcp.connect('localhost', @port, [:binary, packet: :line])
    socket
  end

  def welcome_msg, do: List.foldl(@welcome_messages, "", &(&1 <> &2 <> "\r\n"))

  setup_all do
    {:ok, _pid} = ExIRCd.start([], [])
    :ok
  end

  setup do
    socket = new_client()
    %{socket: socket}
  end

  test "Basic registration scanario: user -> nick", %{socket: socket} do
    socket
    |> Client.user(@login, "Voldemar", "Duletskiy")
    |> Client.nick(@nick)

    msg = welcome_msg()
    assert_receive {:tcp, socket, msg}
  end

  test "Upsidedown: nick -> user", %{socket: socket} do
    socket
    |> Client.nick(@nick)
    |> Client.user(@login, "Voldemar", "Duletskiy")

    msg = welcome_msg()
    assert_receive {:tcp, ^socket, msg}
  end

  test "nick already exists", %{socket: socket} do
    socket
    |> Client.user(@login, "Voldemar", "Duletskiy")
    |> Client.nick(@nick)

    msg = welcome_msg()
    assert_receive {:tcp, _, msg}

    somebody = new_client() |> Client.nick(@nick)

    assert_receive {:tcp, somebody, "433 " <> _}
  end
end
