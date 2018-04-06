defmodule IRC.ServerTest do
  use ExUnit.Case

  alias IRC.Client

  @port 6667
  @nick "voldemar"
  @login @nick
  @first_name "Voldemar"
  @last_name "Duletskiy"

  @welcome_messages [
    "001 Welcome to the Internet Relay Network #{@nick}!#{@login}@127.0.0.1>",
    "002 Your host is Ironclad, running version 0.0.1 alpha",
    "003 This server was created Sat Mar 3 2018 at 03:57:37 EDT",
    "004 Ironclad 0.0.1 alpha aiwroOs asdasdasdasd"
  ]

  def check_welcome(socket) do
    Enum.each(@welcome_messages, fn (msg) ->
      msg = "#{msg}\r\n"
      assert_receive {:tcp, ^socket, ^msg}
    end)
  end

  setup_all do
    {:ok, _pid} = ExIRCd.start([], [])
    :ok
  end

  describe "Registration" do
    setup do
      socket = Client.new(@port)
      %{socket: socket}
    end

    test "Basic registration scanario: user -> nick", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome
    end

    test "Upsidedown: nick -> user", %{socket: socket} do
      socket
      |> Client.nick(@nick)
      |> Client.user(@login, @first_name, @last_name)
      |> check_welcome
    end

    test "nick already exists", %{socket: socket} do
      socket
      |> Client.user(@login, @first_name, @last_name)
      |> Client.nick(@nick)
      |> check_welcome

      somebody = Client.new(@port) |> Client.nick(@nick)

      assert_receive {:tcp, ^somebody, "433 " <> _}
    end
  end

  describe "Messaging between users" do
    setup do
      %{
        rick: Client.new(@port) |> Client.register("rick",  "Rich", "Sanchez"),
        morty: Client.new(@port) |> Client.register("morty", "Morty", "Smith")
      }
    end

    @tag :skip
    test "One user messages to another", %{rick: rick, morty: morty} do
      msg = "Hello morty"
      Client.write(morty, "PRIVMSG rick :#{msg}")

      assert_receive {:tcp, rick, ":rick!rick@127.0.0.1 PRIVMSG :Hello morty"}
    end

    test "Allow messaging for registered users" do
      client = Client.new(@port)
      Client.write(client, "PRIVMSG somebody :Some text")

      assert_receive {:tcp, client, "451 :You have not registered\r\n"}
    end
  end
end
